
from sdl2 import *
from sdl2.ext.compat import byteify
import OpenGL
#OpenGL.ERROR_CHECKING = False
from OpenGL.GL import *
from OpenGL.GLU import *

import pym
import functools
import numpy
import ctypes
from sdl2.ext import Resources

PyBUF_READ = 0x100
PyBUF_WRITE = 0x200

RESOURCES = Resources(__file__, "assets")

# From:
# http://larsnordeide.com/2014/pysdl2-playing-a-sound-from-a-wav-file.html
#
class WavSound(object):
    def __init__(self, file, pcm):
        super(WavSound, self).__init__()
        self._buf = POINTER(Uint8)()
        self._length = Uint32()
        self._bufpos = 0

        self.pcm = pcm
        self.want_spec = SDL_AudioSpec(freq = 48000, aformat = AUDIO_F32,channels = 2, samples = 512)
        #self.want_spec = SDL_AudioSpec(freq = 0 ,aformat = 0,channels = 0, samples = 0)
        self.have_spec = SDL_AudioSpec(freq = 0 ,aformat = 0,channels = 0, samples = 0)
        
        self.done = False
        self._load_file(file)
        self.want_spec.callback = SDL_AudioCallback(self._play_next)
 
    def __del__(self):
        SDL_FreeWAV(self._buf)
 
    def _load_file(self, file):
        rw = SDL_RWFromFile(byteify(file, "utf-8"), b"rb")
        sp = SDL_LoadWAV_RW(rw, 1, ctypes.byref(self.want_spec), ctypes.byref(self._buf), ctypes.byref(self._length))
        if sp is None:
            raise RuntimeError("Could not open audio file: {}".format(SDL_GetError()))
 
    def _play_next(self, notused, stream, len):
        #print("In Callback %d " % len)
        length = self._length.value
        numbytes = min(len, length - self._bufpos)
        for i in range(0, numbytes):
            stream[i] = self._buf[self._bufpos + i]
        self._bufpos += numbytes
 
        # If not enough bytes in buffer, add silence
        rest = min(0, len - numbytes)
        for i in range(0, rest):
            stream[i] = 0
 
        # Are we done playing sound?
        if self._bufpos == length:
            self.done = True

        #
        # https://stackoverflow.com/questions/4355524/getting-data-from-ctypes-array-into-numpy
        #

        buffer_from_memory = ctypes.pythonapi.PyMemoryView_FromMemory
        buffer_from_memory.restype = ctypes.py_object
        buffer = buffer_from_memory(stream, len, PyBUF_WRITE)
        stream_out = numpy.frombuffer(buffer, numpy.float32)
        #for i in range(10):
        #    print("Data2 %f" % stream_out[i])
        self.pcm.addPCMfloat(stream_out)


class PmSdl(object):    
    def __init__(self, settings, flags):
        self.width = settings.windowWidth
        self.height = settings.windowHeight
        self.done = 0
        self.isFullScreen = False
        self.pym = pym.Pym(settings,flags)
        pass

    def init(self, window, renderer):
        self.win = window;
        self.rend = renderer;
        #self.pym.selectRandom(True);
        self.pym.resetGL(self.width, self.height);
        pass

    def play_audio(self, filename):
        sound_file = RESOURCES.get_path(filename)
        self.sound = WavSound(sound_file, self.pym.PCM())

        self.devid = SDL_OpenAudioDevice(None, 0, self.sound.want_spec, self.sound.have_spec, 0)

        if self.devid == 0:
            raise RuntimeError("Unable to open audio device: {}".format(SDL_GetError()))

        if self.sound.want_spec.format != self.sound.have_spec.format:
            raise RuntimeError("Unable to get Float32 audio: {}".format(SDL_GetError()))
        print ("Format {}".format(self.sound.have_spec.format))
        SDL_PauseAudioDevice(self.devid, 0)
        

    def toggleFullScreen(self):
        self.pym.maximize()
        if self.isFullScreen:
            SDL_SetWindowFullscreen(win, SDL_WINDOW_FULLSCREEN_DESKTOP)
            self.isFullScreen = False
            SDL_ShowCursor(True)
        else:
            SDL_ShowCursor(False)
            SDL_SetWindowFullscreen(win, SDL_WINDOW_FULLSCREEN)
            self.isFullScreen = True

    def resize(self, width, height):
        self.width = width
        self.height = height
        #self.pym.settings.windowWidth = width
        #self.pym.settings.windowHeight = height
        self.pym.resetGL(width, height)
        pass

    def renderFrame(self):
        glClearColor( 0.0, 0.0, 0.0, 0.0 )
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        self.pym.renderFrame()
        glFlush()

        SDL_RenderPresent(self.rend)
        pass



    def pollEvent(self):
        evt = SDL_Event()

        SDL_PollEvent(evt)
        if evt.type == SDL_WINDOWEVENT:
            if evt.window.event == SDL_WINDOWEVENT_RESIZED:
                self.resize(evt.window.data1, evt.window.data2)
        elif evt.type == SDL_KEYDOWN:
            self.keyHandler(evt)
        elif evt.type == SDL_QUIT:
            self.done = True;


    def maximize(self):
        dm = SDL_DisplayMode()
        if SDL_GetDesktopDisplayMode(0, dm) != 0:
            SDL_Log("SDL_GetDesktopDisplayMode failed: %s", SDL_GetError());
            return
        

        SDL_SetWindowSize(self.win, dm.w, dm.h)
        self.pym.resize(dm.w, dm.h)
        
    def keyHandler(self, sdl_evt):
        pass
        # TODO:
        # projectMEvent evt;
        # projectMKeycode key;
        # projectMModifier mod;
        # SDL_Keymod sdl_mod = (SDL_Keymod) sdl_evt->key.keysym.mod;
        # SDL_Keycode sdl_keycode = sdl_evt->key.keysym.sym;

        # // handle keyboard input (for our app first, then projectM)
        # switch (sdl_keycode) {
        #     case SDLK_f:
        #         if (sdl_mod & KMOD_LGUI || sdl_mod & KMOD_RGUI || sdl_mod & KMOD_LCTRL) {
        #             // command-f: fullscreen
        #             toggleFullScreen();
        #             return; // handled
        #         }
        #         break;
        # }

        # // translate into projectM codes and perform default projectM handler
        # evt = sdl2pmEvent(sdl_evt);
        # key = sdl2pmKeycode(sdl_keycode);
        # mod = sdl2pmModifier(sdl_mod);
        # key_handler(evt, key, mod);