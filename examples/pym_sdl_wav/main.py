import sys
import ctypes

import OpenGL
#
# Project M throws GL_INVALID_VALUE occasionally.
# disable error checking for now...
#
OpenGL.ERROR_CHECKING = False 

from sdl2 import *
import pym 
import pm_sdl_wav



def main():
    SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)
    window = SDL_CreateWindow(b"Hello World",
                              SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                              592, 460, SDL_WINDOW_RESIZABLE)

    render = SDL_CreateRenderer(window, 0, SDL_RENDERER_ACCELERATED);
    # if (! rend) {
    #     fprintf(stderr, "Failed to create renderer: %s\n", SDL_GetError());
    #     SDL_Quit();
    # }
    SDL_SetWindowTitle(window, b"projectM Visualizer");

    #SDL_FreeSurface(image)
    FPS = 60
    # // init projectM
    settings = pym.Settings()
    settings.windowWidth = 592
    settings.windowHeight = 460
    settings.meshX = 1
    settings.meshY = 1
    settings.fps   = FPS
    settings.textureSize = 2048
    settings.smoothPresetDuration = 3
    settings.presetDuration = 7
    settings.beatSensitivity = 0.8
    settings.aspectCorrection = 1
    settings.easterEgg = 0
    settings.shuffleEnabled = 1
    settings.softCutRatingsEnabled = 1
    base_path = ""
    settings.presetURL = base_path + "/home/bryan/projectm/src/projectM-sdl/presets/presets_milkdrop_200/";
    settings.menuFontURL = base_path + "fonts/Vera.ttf";
    settings.titleFontURL = base_path + "fonts/Vera.ttf";

    app = pm_sdl_wav.PmSdl(settings, 0)
    app.init(window, render)
    
    # get an audio input device
    app.play_audio("Firefly.wav")
    
    # standard main loop
    frame_delay = 1000/FPS;
    last_time = SDL_GetTicks();
    while not app.done:
        app.renderFrame()
        app.pollEvent()
        elapsed = SDL_GetTicks() - last_time
        if elapsed < frame_delay:
            deltat = frame_delay - elapsed
            #print("Dt: %d" % int(deltat) )
            SDL_Delay(int(deltat))
        last_time = SDL_GetTicks()
    

    SDL_DestroyWindow(window)
    SDL_Quit()
    return 0

if __name__ == "__main__":
    sys.exit(main())
