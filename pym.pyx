cimport cython
from libcpp.memory cimport unique_ptr
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool
from cython.operator cimport dereference as deref
from ctypes import POINTER

from ctypes import c_int, c_int8, c_uint8, c_int16, c_uint16, c_int32, \
    c_uint32, c_int64, c_uint64, c_size_t, c_void_p, c_char_p

# cython -3 --cplus --directive c_string_type=str --directive c_string_encoding=ascii --fast-fail --include-dir /home/bwalsh/proj/install/include/ pym.pyx
# cdef extern from "event.h":
#     cdef enum  MEvent "projectMEvent":
#         PROJECTM_KEYUP,
#         PROJECTM_KEYDOWN,
#         PROJECTM_VIDEORESIZE,
#         PROJECTM_VIDEOQUIT

#     cdef enum MKeycode "projectMKeycode":
#         PROJECTM_K_RETURN,
#         PROJECTM_K_RIGHT,
#         PROJECTM_K_LEFT,
#         PROJECTM_K_UP,
#         PROJECTM_K_DOWN,
#         PROJECTM_K_PAGEUP,
#         PROJECTM_K_PAGEDOWN,
#         PROJECTM_K_INSERT,
#         PROJECTM_K_DELETE,
#         PROJECTM_K_ESCAPE,
#         PROJECTM_K_LSHIFT,
#         PROJECTM_K_RSHIFT,
#         PROJECTM_K_CAPSLOCK,
#         PROJECTM_K_LCTRL,
#         PROJECTM_K_HOME,
#         PROJECTM_K_END,
#         PROJECTM_K_BACKSPACE,

#         PROJECTM_K_F1,
#         PROJECTM_K_F2,
#         PROJECTM_K_F3,
#         PROJECTM_K_F4,
#         PROJECTM_K_F5,
#         PROJECTM_K_F6,
#         PROJECTM_K_F7,
#         PROJECTM_K_F8,
#         PROJECTM_K_F9,
#         PROJECTM_K_F10,
#         PROJECTM_K_F11,
#         PROJECTM_K_F12,

#         PROJECTM_K_0 = 48,
#         PROJECTM_K_1,
#         PROJECTM_K_2,
#         PROJECTM_K_3,
#         PROJECTM_K_4,
#         PROJECTM_K_5,
#         PROJECTM_K_6,
#         PROJECTM_K_7,
#         PROJECTM_K_8,
#         PROJECTM_K_9,

#         PROJECTM_K_A = 65,
#         PROJECTM_K_B,
#         PROJECTM_K_C,
#         PROJECTM_K_D,
#         PROJECTM_K_E,
#         PROJECTM_K_F,
#         PROJECTM_K_G,
#         PROJECTM_K_H,
#         PROJECTM_K_I,
#         PROJECTM_K_J,
#         PROJECTM_K_K,
#         PROJECTM_K_L,
#         PROJECTM_K_M,
#         PROJECTM_K_N,
#         PROJECTM_K_O,
#         PROJECTM_K_P,
#         PROJECTM_K_Q,
#         PROJECTM_K_R,
#         PROJECTM_K_S,
#         PROJECTM_K_T,
#         PROJECTM_K_U,
#         PROJECTM_K_V,
#         PROJECTM_K_W,
#         PROJECTM_K_X,
#         PROJECTM_K_Y,
#         PROJECTM_K_Z,

#         PROJECTM_K_a = 97,
#         PROJECTM_K_b,
#         PROJECTM_K_c,
#         PROJECTM_K_d,
#         PROJECTM_K_e,
#         PROJECTM_K_f,
#         PROJECTM_K_g,
#         PROJECTM_K_h,
#         PROJECTM_K_i,
#         PROJECTM_K_j,
#         PROJECTM_K_k,
#         PROJECTM_K_l,
#         PROJECTM_K_m,
#         PROJECTM_K_n,
#         PROJECTM_K_o,
#         PROJECTM_K_p,
#         PROJECTM_K_q,
#         PROJECTM_K_r,
#         PROJECTM_K_s,
#         PROJECTM_K_t,
#         PROJECTM_K_u,
#         PROJECTM_K_v,
#         PROJECTM_K_w,
#         PROJECTM_K_x,
#         PROJECTM_K_y,
#         PROJECTM_K_z,
#         PROJECTM_K_NONE,
#         PROJECTM_K_PLUS,
#         PROJECTM_K_MINUS,
#         PROJECTM_K_EQUALS

#     cdef enum MModifier "MModifier":
#         PROJECTM_KMOD_LSHIFT,
#         PROJECTM_KMOD_RSHIFT,
#         PROJECTM_KMOD_CAPS,
#         PROJECTM_KMOD_LCTRL,
#         PROJECTM_KMOD_RCTRL


ctypedef int projectMEvent
ctypedef int projectMKeycode
ctypedef int projectMModifier

cdef extern from "projectM.hpp" :

    cdef cppclass CSettings "projectM::Settings":

        CSettings()

        int meshX
        int meshY
        int fps
        int textureSize
        int windowWidth
        int windowHeight
        string presetURL
        string titleFontURL
        string menuFontURL
        int smoothPresetDuration
        int presetDuration
        float beatSensitivity
        bool aspectCorrection
        float easterEgg
        bool shuffleEnabled
        bool softCutRatingsEnabled

    cdef cppclass CProjectM "projectM":
        #static const int FLAG_NONE = 0;
        #static const int FLAG_DISABLE_PLAYLIST_LOAD = 1 << 0;

        CProjectM(CSettings settings, int flags)
        #CProjectM(string config_file, int flags)

        void projectM_resetGL( int width, int height ) except *
        void projectM_resetTextures() except *
        void projectM_setTitle( string title ) except *
        void renderFrame() except *
        unsigned initRenderToTexture() except *
        void key_handler( projectMEvent event,
		    projectMKeycode keycode, projectMModifier modifier ) except *


        void changeTextureSize(int size) except *
        void changePresetDuration(int seconds) except *
        void getMeshSize(int *w, int *h) except *

        # Sets preset iterator position to the passed in index
        void selectPresetPosition(unsigned int index) except *

        # Plays a preset immediately
        void selectPreset(unsigned int index, bool hardCut) except *

        # Removes a preset from the play list. If it is playing then it will continue as normal until next switch
        void removePreset(unsigned int index) except *

        # Sets the randomization functor. If set to null, the traversal will move in order according to the playlist
        # void setRandomizer(RandomizerFunctor * functor) except *

        # Tell projectM to play a particular preset when it chooses to switch
        # If the preset is locked the queued item will be not switched to until the lock is released
        # Subsequent calls to this function effectively nullifies previous calls.
        #void queuePreset(unsigned int index) except *

        # Returns true if a preset is queued up to play next
        #bool isPresetQueued() except *

        # Removes entire playlist, The currently loaded preset will end up sticking until new presets are added
        void clearPlaylist() except *

        # Turn on or off a lock that prevents projectM from switching to another preset
        void setPresetLock(bool isLocked) except *

        # Returns true if the active preset is locked
        bool isPresetLocked() except *

        # Returns index of currently active preset. In the case where the active
        # preset was removed from the playlist, this function will return the element
        # before active preset (thus the next in order preset is invariant with respect
        # to the removal)
        bool selectedPresetIndex(unsigned int & index) except *

        # Add a preset url to the play list. Appended to bottom. Returns index of preset
        unsigned int addPresetURL(string presetURL, string presetName, const vector[int] & ratingList) except *

        # Insert a preset url to the play list at the suggested index.
        void insertPresetURL(unsigned int index, const string & presetURL, const string & presetName, const vector[int]& ratingList) except *

        # Returns true if the selected preset position points to an actual preset in the
        # currently loaded playlist
        bool presetPositionValid() except *

        # Returns the url associated with a preset index
        string getPresetURL(unsigned int index) except *

        # Returns the preset name associated with a preset index
        string getPresetName ( unsigned int index ) except *
    
        void changePresetName ( unsigned int index, string name )

        # Returns the rating associated with a preset index
        #int getPresetRating (unsigned int index, const PresetRatingType ratingType);

        #void changePresetRating (unsigned int index, int rating, const PresetRatingType ratingType);  

        # Returns the size of the play list
        unsigned int getPlaylistSize() except *

        void evaluateSecondPreset()

        void setShuffleEnabled(bool value) except *

        bool isShuffleEnabled() except *

        # Occurs when active preset has switched. Switched to index is returned
        # void presetSwitchedEvent(bool isHardCut, unsigned int index) const {};
        # void shuffleEnabledValueChanged(bool isEnabled) const {};
        # void presetSwitchFailedEvent(bool hardCut, unsigned int index, const std::string & message) const {};


        # Occurs whenever preset rating has changed via changePresetRating() method
        # void presetRatingChanged(unsigned int index, int rating, PresetRatingType ratingType) const {};


        CPCM* pcm() except *

        #void *thread_func(void *vptr_args);
        #PipelineContext & pipelineContext() { return *_pipelineContext; }
        #PipelineContext & pipelineContext2() { return *_pipelineContext2; }


        void selectPrevious(bool) except *
        void selectNext(const bool) except *
        void selectRandom(const bool) except *





cdef extern from "PCM.hpp":
    cdef cppclass CPCM "PCM":
        PCM()
        void initPCM(int maxsamples) except *
        void addPCMfloat(const float *PCMdata, int samples) except *
        void addPCM16(short [2][512]) except *
        void addPCM16Data(const short* pcm_data, short samples) except *
        void addPCM8( unsigned char [2][1024]) except *
        void addPCM8_512( const unsigned char [2][512]) except *
        void getPCM(float *data, int samples, int channel, int freq, float smoothing, int derive) except *
        void freePCM() except *
        int getPCMnew(float *PCMdata, int channel, int freq, float smoothing, int derive,int reset) except *

cdef class Settings:
    cdef CSettings c_settings

    def __cinit__(self):
        self.c_settings = CSettings()
        self.c_settings.meshX = 0
        self.c_settings.meshY = 0 
        self.c_settings.fps = 0
        self.c_settings.textureSize = 0
        self.c_settings.windowWidth = 0
        self.c_settings.windowHeight = 0
        #self.c_settings.presetURL = ""
        #self.c_settings.titleFontURL = ""
        #self.c_settings.menuFontURL = ""
        self.c_settings.smoothPresetDuration = 0
        self.c_settings.presetDuration = 0
        self.c_settings.beatSensitivity = 0
        self.c_settings.aspectCorrection = 0
        self.c_settings.easterEgg = 0
        self.c_settings.shuffleEnabled = 0
        self.c_settings.softCutRatingsEnabled = 0
    
    @property
    def meshX(self):
        return self.c_settings.meshX

    @meshX.setter
    def meshX(self, value):
        self.c_settings.meshX = value
    
    @property
    def meshY(self):
        return self.c_settings.meshY

    @meshY.setter
    def meshY(self, value):
        self.c_settings.meshY = value

    @property
    def fps(self):
        return self.c_settings.fps

    @fps.setter
    def fps(self, value):
        self.c_settings.fps = value

    @property
    def textureSize(self):
        return self.c_settings.textureSize

    @textureSize.setter
    def textureSize(self, value):
        self.c_settings.textureSize = value

    @property
    def windowWidth(self):
        return self.c_settings.windowWidth

    @windowWidth.setter
    def windowWidth(self, value):
        self.c_settings.windowWidth = value 

    @property
    def windowHeight(self):
        return self.c_settings.windowHeight

    @windowHeight.setter
    def windowHeight(self, value):
        self.c_settings.windowHeight = value 

    @property
    def presetURL(self):
        return self.c_settings.presetURL

    @presetURL.setter
    def presetURL(self, value):
        self.c_settings.presetURL = value.encode('UTF-8')  

    @property
    def titleFontURL(self):
        return self.c_settings.titleFontURL

    @titleFontURL.setter
    def titleFontURL(self, value):
        self.c_settings.titleFontURL = value.encode('UTF-8') 

    @property
    def menuFontURL(self):
        return self.c_settings.menuFontURL

    @menuFontURL.setter
    def menuFontURL(self, value):
        self.c_settings.menuFontURL = value.encode('UTF-8') 

    @property
    def smoothPresetDuration(self):
        return self.c_settings.smoothPresetDuration

    @smoothPresetDuration.setter
    def smoothPresetDuration(self, value):
        self.c_settings.smoothPresetDuration = value 

    @property
    def presetDuration(self):
        return self.c_settings.presetDuration

    @presetDuration.setter
    def presetDuration(self, value):
        self.c_settings.presetDuration = value 

    @property
    def beatSensitivity(self):
        return self.c_settings.beatSensitivity

    @beatSensitivity.setter
    def beatSensitivity(self, value):
        self.c_settings.beatSensitivity = value 

    @property
    def aspectCorrection(self):
        return self.c_settings.aspectCorrection

    @aspectCorrection.setter
    def aspectCorrection(self, value):
        self.c_settings.aspectCorrection = value 
 
    @property
    def easterEgg(self):
        return self.c_settings.easterEgg

    @easterEgg.setter
    def easterEgg(self, value):
        self.c_settings.easterEgg = value 
 
    @property
    def shuffleEnabled(self):
        return self.c_settings.shuffleEnabled

    @shuffleEnabled.setter
    def shuffleEnabled(self, value):
        self.c_settings.shuffleEnabled = value 
 
    @property
    def softCutRatingsEnabled(self):
        return self.c_settings.softCutRatingsEnabled

    @softCutRatingsEnabled.setter
    def softCutRatingsEnabled(self, value):
        self.c_settings.softCutRatingsEnabled = value 


cdef class Pym:

    cdef unique_ptr[CProjectM] thisptr

    #def __cinit__(self, config_file, flags = FLAG_NONE):
    def __cinit__(self, Settings settings, flags):
        cdef CSettings s = settings.c_settings
        self.thisptr.reset(new CProjectM(s, flags))

    def resetGL(self, width, height) :
        deref(self.thisptr).projectM_resetGL(width, height)

    def resetTextures(self):
        deref(self.thisptr).projectM_resetTextures()

    def setTitle(self, title):
        deref(self.thisptr).projectM_setTitle(title)

    def renderFrame(self):
        deref(self.thisptr).renderFrame()

    
    def initRenderToTexture(self):
        return deref(self.thisptr).initRenderToTexture()
 
    def key_handler(self, event, keycode, modifier):
        deref(self.thisptr).key_handler(event, keycode, modifier )

    def changeTextureSize(self, size):
        deref(self.thisptr).changeTextureSize(size)

    def changePresetDuration(self, seconds):
        deref(self.thisptr).changePresetDuration(seconds)

    def getMeshSize(self):
        cdef int width, height
        deref(self.thisptr).getMeshSize(&width, &height)
        return width, height

    # Sets preset iterator position to the passed in index
    def selectPresetPosition(self, index):
        deref(self.thisptr).selectPresetPosition(index)

    # Plays a preset immediately
    def selectPreset(self, index, hardCut):
        deref(self.thisptr).selectPreset(index, hardCut)

    # Removes a preset from the play list. If it is playing then it will continue as normal until next switch
    def removePreset(self, index):
        deref(self.thisptr).removePreset(index) 

    # # Sets the randomization functor. If set to null, the traversal will move in order according to the playlist
    # # void setRandomizer(RandomizerFunctor * functor) except *

    # Tell projectM to play a particular preset when it chooses to switch
    # If the preset is locked the queued item will be not switched to until the lock is released
    # Subsequent calls to this function effectively nullifies previous calls.
    #def queuePreset(self, index):
    #    deref(self.thisptr).queuePreset(index)

    # Returns true if a preset is queued up to play next
    #def isPresetQueued(self): 
    #    return deref(self.thisptr).isPresetQueued()

    # Removes entire playlist, The currently loaded preset will end up sticking until new presets are added
    def clearPlaylist(self):
        deref(self.thisptr).clearPlaylist()

    # Turn on or off a lock that prevents projectM from switching to another preset
    def setPresetLock(self, isLocked):
        deref(self.thisptr).setPresetLock(isLocked)

    # Returns true if the active preset is locked
    def isPresetLocked(self):
        deref(self.thisptr).isPresetLocked()

    # Returns index of currently active preset. In the case where the active
    # preset was removed from the playlist, this function will return the element
    # before active preset (thus the next in order preset is invariant with respect
    # to the removal)
    def selectedPresetIndex(self):
        cdef unsigned int index = 0
        cdef valid = deref(self.thisptr).selectedPresetIndex(index)
        return valid, index

    # Add a preset url to the play list. Appended to bottom. Returns index of preset
    def addPresetURL(self, presetURL, presetName, ratingList):
        cdef vector[int] in_list
        cdef string in_preset_url = presetURL.encode('UTF-8') 
        cdef string in_preset_name = presetName.encode('UTF-8') 
        
        for r in ratingList:
            in_list.push_back(r)
        
        return deref(self.thisptr).addPresetURL(in_preset_url, in_preset_name, in_list)

    # Insert a preset url to the play list at the suggested index.
    def insertPresetURL(self, index, presetURL, presetName, ratingList):
        cdef vector[int] in_list
        cdef string in_preset_url = presetURL.encode('UTF-8') 
        cdef string in_preset_name = presetName.encode('UTF-8') 
        
        for r in ratingList:
            in_list.push_back(r)
        deref(self.thisptr).insertPresetURL(index, presetURL, presetName, ratingList)

    # Returns true if the selected preset position points to an actual preset in the
    # currently loaded playlist
    def presetPositionValid(self):
        return deref(self.thisptr).presetPositionValid()

    # Returns the url associated with a preset index
    def getPresetURL(self, index):
        return deref(self.thisptr).getPresetURL(index)

    # Returns the preset name associated with a preset index
    def getPresetName(self, index):
        return deref(self.thisptr).getPresetName (index )
    
    def changePresetName (self, index, name):
        deref(self.thisptr).changePresetName (index, name)

    # # Returns the rating associated with a preset index
    # #int getPresetRating (unsigned int index, const PresetRatingType ratingType);

    # #void changePresetRating (unsigned int index, int rating, const PresetRatingType ratingType);  

    # # Returns the size of the play list
    def getPlaylistSize(self):
        return deref(self.thisptr).getPlaylistSize()

    def evaluateSecondPreset(self):
        deref(self.thisptr).evaluateSecondPreset()

    def setShuffleEnabled(self, value):
        deref(self.thisptr).setShuffleEnabled(value)

    def isShuffleEnabled(self):
        return deref(self.thisptr).isShuffleEnabled()

    def PCM(self):
        cdef CPCM* p = deref(self.thisptr).pcm()
        return PCM.wrap_pcm(deref(self.thisptr).pcm())

    def selectPrevious(self, flag):
        deref(self.thisptr).selectPrevious(flag)

    def selectNext(self, flag):
        deref(self.thisptr).selectNext(flag)

    def selectRandom(self, flag):
        deref(self.thisptr).selectRandom(flag)


cdef class FloatPointer:
    cdef unsigned char *fp_instance

    @staticmethod
    cdef create(unsigned char* p):
        cdef FloatPointer pc = FloatPointer()
        pc.fp_instance = p
        print ("Created Float Pointer")
        return pc

cdef class PCM:

    cdef CPCM* c_instance
    
    @staticmethod
    cdef wrap_pcm(CPCM* ptr):
        cdef PCM instance = PCM.__new__(PCM)
        instance.c_instance = ptr
        return instance


    def __cinit__(self):
        pass

    def init(self, maxsamples):
        self.c_instance.initPCM(maxsamples)

    def addPCMfloat(self, float[::1] pcm_data):
        #print("Len %d" %len(pcm_data))
        #for i in range(10):
        #    print("Data %f" % pcm_data[i])
        self.c_instance.addPCMfloat(&pcm_data[0], len(pcm_data))


    #def addPCM16(self, short [:2, :512]  pcm16):
    #    self.c_instance.addPCM16(pcm16);

    def addPCM16Data(self, short[::1] pcm_data) :
        #print("Len %d" %len(pcm_data))
        #for i in range(10):
        #    print("Data %f" % pcm_data[i])
        self.c_instance.addPCM16Data(&pcm_data[0], len(pcm_data))

    #def addPCM8(self, unsigned char [:,:] pcm8):
    #    self.c_instance.addPCM8(pcm8)

    #def addPCM8_512(self, unsigned char [:,:] pcm8_512):
    #    self.c_instance.addPCM8_512(pcm8_512)

    #def getPCM(self, data, samples, channel, freq, smoothing, derive):
    #    self.c_instance.getPCM(float *data, int samples, int channel, int freq, float smoothing, int derive)

    #def freePCM()
    #    self.c_instance.freePCM()


    #int getPCMnew(float *PCMdata, int channel, int freq, float smoothing, int derive,int reset);
