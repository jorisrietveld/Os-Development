;__________________________________________________________________________________________/ fancy_headers.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 14-01-2018 08:55
;   
;   Description:
;
%ifndef FANCY_HEADER_ASM_INCLUDED
%define FANCY_HEADER_ASM_INCLUDED

%define USE_FANCY_HEADER_0x1C 1
; 2
; 11
; 14
; 15
;16 3d
; 17
; 18
; 0D
; 19
; 55
; 1C 3d
%ifdef USE_FANCY_HEADER_0x01
msgFancyHeader:
db '================================================================================', 0x0A
db '     ___  ________  ________  ___     ___    ___      ________  ________        ', 0x0A
db '    |\  \|\   __  \|\   __  \|\  \   |\  \  /  /|    |\   __  \|\   ____\       ', 0x0A
db '    \ \  \ \  \|\  \ \  \|\  \ \  \  \ \  \/  / /    \ \  \|\  \ \  \___|_      ', 0x0A
db '  __ \ \  \ \  \\\  \ \   _  _\ \  \  \ \    / /      \ \  \\\  \ \_____  \     ', 0x0A
db ' |\  \\_\  \ \  \\\  \ \  \\  \\ \  \  /     \/        \ \  \\\  \|____|\  \    ', 0x0A
db ' \ \________\ \_______\ \__\\ _\\ \__\/  /\   \         \ \_______\____\_\  \   ', 0x0A
db '  \|________|\|_______|\|__|\|__|\|__/__/ /\ __\         \|_______|\_________\  ', 0x0A
db '                                     |__|/ \|__|                  \|_________|  ', 0x0A
db '                                                                                ', 0x0A
db '================================================================================', 0x0A
db 0x00 ; NULL byte string terminator.

%elifdef USE_FANCY_HEADER_0x02
msgFancyHeader:
db '                                                                  ', 0x0A
db '       **                 **                 *******    ********  ', 0x0A
db '      /**                //                 **/////**  **//////   ', 0x0A
db '      /**  ******  ****** ** **   **       **     //**/**         ', 0x0A
db '      /** **////**//**//*/**//** **       /**      /**/*********  ', 0x0A
db '      /**/**   /** /** / /** //***        /**      /**////////**  ', 0x0A
db '  **  /**/**   /** /**   /**  **/**       //**     **        /**  ', 0x0A
db ' //***** //****** /***   /** ** //**       //*******   ********   ', 0x0A
db '  /////   //////  ///    // //   //         ///////   ////////    ', 0x0A
db 0x00 ; NULL byte string terminator.

%elifdef USE_FANCY_HEADER_0x03
msgFancyHeader:
db '     888                 ,e,                  ,88~-_   ,d88~~\  ', 0x0A
db '     888  e88~-_  888-~\  "  Y88b  /         d888   \  8888     ', 0x0A
db '     888 d888   i 888    888  Y88b/         88888    | `Y88b    ', 0x0A
db '     888 8888   | 888    888   Y88b         88888    |  `Y88b,  ', 0x0A
db ' |   88P Y888   ` 888    888   /Y88b         Y888   /     8888  ', 0x0A
db '  \__8"   "88_-~  888    888  /  Y88b         `88_-~   \__88P`  ', 0x0A
db '                                                                 ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x04
msgFancyHeader:
db ' ::::::::::::::::::: ::::::::: ::::::::::::::    :::      ::::::::  ::::::::   ', 0x0A
db '     :+:   :+:    :+::+:    :+:    :+:    :+:    :+:     :+:    :+::+:    :+:  ', 0x0A
db '     +:+   +:+    +:++:+    +:+    +:+     +:+  +:+      +:+    +:++:+         ', 0x0A
db '     +#+   +#+    +:++#++:++#:     +#+      +#++:+       +#+    +:++#++:++#++  ', 0x0A
db '     +#+   +#+    +#++#+    +#+    +#+     +#+  +#+      +#+    +#+       +#+  ', 0x0A
db ' #+# #+#   #+#    #+##+#    #+#    #+#    #+#    #+#     #+#    #+##+#    #+#  ', 0x0A
db '  #####     ######## ###    #################    ###      ########  ########   ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x05
msgFancyHeader:
db '      ::::::::::::::::::: ::::::::: ::::::::::::::    :::         ::::::::  ::::::::  ', 0x0A
db '         :+:   :+:    :+::+:    :+:    :+:    :+:    :+:        :+:    :+::+:    :+:  ', 0x0A
db '        +:+   +:+    +:++:+    +:+    +:+     +:+  +:+         +:+    +:++:+          ', 0x0A
db '       +#+   +#+    +:++#++:++#:     +#+      +#++:+          +#+    +:++#++:++#++    ', 0x0A
db '      +#+   +#+    +#++#+    +#+    +#+     +#+  +#+         +#+    +#+       +#+     ', 0x0A
db ' #+# #+#   #+#    #+##+#    #+#    #+#    #+#    #+#        #+#    #+##+#    #+#      ', 0x0A
db ' #####     ######## ###    #################    ###         ########  ########        ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x06
msgFancyHeader:
db ' ::::::`##::`#######::`########::`####:`##::::`##:::::`#######:::`######:: ', 0x0A
db ' :::::: ##:`##.... ##: ##.... ##:. ##::. ##::`##:::::`##.... ##:`##... ##: ', 0x0A
db ' :::::: ##: ##:::: ##: ##:::: ##:: ##:::. ##`##:::::: ##:::: ##: ##:::..:: ', 0x0A
db ' :::::: ##: ##:::: ##: ########::: ##::::. ###::::::: ##:::: ##:. ######:: ', 0x0A
db ' `##::: ##: ##:::: ##: ##.. ##:::: ##:::: ## ##:::::: ##:::: ##::..... ##: ', 0x0A
db '  ##::: ##: ##:::: ##: ##::. ##::: ##::: ##:. ##::::: ##:::: ##:`##::: ##: ', 0x0A
db ' . ######::. #######:: ##:::. ##:`####: ##:::. ##::::. #######::. ######:: ', 0x0A
db ' :......::::.......:::..:::::..::....::..:::::..::::::.......::::......::: ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x07
msgFancyHeader:
db ' .######...####...#####...######..##..##...........####....####.. ', 0x0A
db ' .....##..##..##..##..##....##.....####...........##..##..##..... ', 0x0A
db ' .....##..##..##..#####.....##......##............##..##...####.. ', 0x0A
db ' .##..##..##..##..##..##....##.....####...........##..##......##. ', 0x0A
db ' ..####....####...##..##..######..##..##...........####....####.. ', 0x0A
db ' ................................................................ ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x08
msgFancyHeader:
db '   | | / / \ | |_) | | \ \_/   / / \ ( (`  ', 0x0A
db ' \_|_| \_\_/ |_| \ |_| /_/ \   \_\_/ _)_)  ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x09
msgFancyHeader:
db '  _|     .-----.----|__.--.--   |       |     __| ', 0x0A
db ' |       |  _  |   _|  |_   _   |   -   |__     | ', 0x0A
db ' |_______|_____|__| |__|__.__   |_______|_______| ', 0x0A
db '                                                  ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x0A
msgFancyHeader:
db ' .%%%%%%...%%%%...%%%%%...%%%%%%..%%..%%...........%%%%....%%%%.. ', 0x0A
db ' .....%%..%%..%%..%%..%%....%%.....%%%%...........%%..%%..%%..... ', 0x0A
db ' .....%%..%%..%%..%%%%%.....%%......%%............%%..%%...%%%%.. ', 0x0A
db ' .%%..%%..%%..%%..%%..%%....%%.....%%%%...........%%..%%......%%. ', 0x0A
db ' ..%%%%....%%%%...%%..%%..%%%%%%..%%..%%...........%%%%....%%%%.. ', 0x0A
db ' ................................................................ ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x0B
msgFancyHeader:
db '     8                      8"""888""""8  ', 0x0A
db '     8 eeeeeeeeee e e    e  8    88       ', 0x0A
db '     8e8  888   8 8 8    8  8    88eeeee  ', 0x0A
db '     888   88eee8e8eeeeeee  8    8    88  ', 0x0A
db ' e   888   888   88888   8  8    8e   88  ', 0x0A
db ' 8eee888eee888   88888   8  8eeee88eee88  ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x0C
msgFancyHeader:
db '   888888               d8b            .d88888b.  .d8888b.   ', 0x0A
db '     "88b               Y8P           d88P" "Y88bd88P  Y88b  ', 0x0A
db '      888                             888     888Y88b.       ', 0x0A
db '      888 .d88b. 888d888888888  888   888     888 "Y888b.    ', 0x0A
db '      888d88""88b888P"  888`Y8bd8P`   888     888    "Y88b.  ', 0x0A
db '      888888  888888    888  X88K     888     888      "888  ', 0x0A
db '      88PY88..88P888    888.d8""8b.   Y88b. .d88PY88b  d88P  ', 0x0A
db '      888 "Y88P" 888    888888  888    "Y88888P"  "Y8888P"   ', 0x0A
db '    .d88P                                                    ', 0x0A
db '  .d88P"                                                     ', 0x0A
db ' 888P"                                                       ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x0D
msgFancyHeader:
db '  _______              __           _______  _______  ', 0x0A
db ' |   _   |.-----.----.|__|.--.--.  |   _   ||   _   | ', 0x0A
db ' |___|   ||  _  |   _||  ||_   _|  |.  |   ||   1___| ', 0x0A
db ' |.  |   ||_____|__|  |__||__.__|  |.  |   ||____   | ', 0x0A
db ' |:  1   |                         |:  1   ||:  1   | ', 0x0A
db ' |::.. . |                         |::.. . ||::.. . | ', 0x0A
db ' `-------"                         `-------""-------" ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x0E
msgFancyHeader:
db '  _____  _____   ______ _____ _     _       _____  _______ ', 0x0A
db '    |   |     | |_____/   |    \___/       |     | |______ ', 0x0A
db '  __|   |_____| |    \_ __|__ _/   \_      |_____| ______| ', 0x0A
db '                                                           ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x0F
msgFancyHeader:
db '  _ ____ ____ _ _  _    ____ ____  ', 0x0A
db '  | |  | |__/ |  \/     |  | [__   ', 0x0A
db ' _| |__| |  \ | _/\_    |__| ___]  ', 0x0A, 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x10
msgFancyHeader:
db '              :                                       :              ', 0x0A
db '             t#,                                     t#,           . ', 0x0A
db '  itttttttt ;##W.   j.         t                    ;##W.         ;W ', 0x0A
db '  fDDK##DDi:#L:WE   EW,        Ej                  :#L:WE        f#E ', 0x0A
db '     t#E  .KG  ,#D  E##j       E#, :KW,      L    .KG  ,#D     .E#f  ', 0x0A
db '     t#E  EE    ;#f E###D.     E#t  ,#W:   ,KG    EE    ;#f   iWW;   ', 0x0A
db '     t#E f#.     t#iE#jG#W;    E#t   ;#W. jWi    f#.     t#i L##Lffi ', 0x0A
db '     t#E :#G     GK E#t t##f   E#t    i#KED.     :#G     GK tLLG##L  ', 0x0A
db '     t#E  ;#L   LW. E#t  :K#E: E#t     L#W.       ;#L   LW.   ,W#i   ', 0x0A
db '   jfL#E   t#f f#:  E#KDDDD###iE#t   .GKj#K.       t#f f#:   j#E.    ', 0x0A
db '   :K##E    f#D#;   E#f,t#Wi,,,E#t  iWf  i#K.       f#D#;  .D#j      ', 0x0A
db '     G#E     G#t    E#t  ;#W:  E#t LK:    t#E        G#t  ,WK,       ', 0x0A
db '      tE      t     DWi   ,KK: E#t i       tDj        t   EG.        ', 0x0A
db '       .                       ,;.                        ,          ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x11
msgFancyHeader:
db '    ___            _      _____ _____  ', 0x0A
db '   |_  |          (_)    |  _  /  ___| ', 0x0A
db '     | | ___  _ __ ___  _| | | \ `--.  ', 0x0A
db '     | |/ _ \| "__| \ \/ | | | |`--. \ ', 0x0A
db ' /\__/ | (_) | |  | |>  <\ \_/ /\__/ / ', 0x0A
db ' \____/ \___/|_|  |_/_/\_ \___/\____/  ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x12
msgFancyHeader:
db '                           )  (      ', 0x0A
db '                        ( /(  )\ )   ', 0x0A
db '    (      (  (     )   )\())(()/(   ', 0x0A
db '    )\  (  )( )\ ( /(  ((_)\  /(_))  ', 0x0A
db '   ((_) )\(()((_))\())   ((_)(_))    ', 0x0A
db '  _ | |((_)((_|_|(_)\   / _ \/ __|   ', 0x0A
db ' | || / _ \ "_| \ \ /  | (_) \__ \   ', 0x0A
db '  \__/\___/_| |_/_\_\   \___/|___/  ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x13
msgFancyHeader:
db "    .-.         _       .--. .--.  ", 0x0A
db "    : :        :_;     : ,. : .--' ", 0x0A
db "  _ : :.--..--..-.-.,- : :: `. `.  ", 0x0A
db " : :; ' .; : ..: `.  . : :; :_`, : ", 0x0A
db " `.__.`.__.:_; :_:_,._ `.__.`.__.' ", 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x14
msgFancyHeader:
db '      ____                                   ____     ____    ', 0x0A
db '      `MM"              68b                 6MMMMb   6MMMMb\  ', 0x0A
db '       MM               Y89                8P    Y8 6M"    `  ', 0x0A
db '       MM  _____ ___  _________   ___     6M      MbMM        ', 0x0A
db '       MM 6MMMMMb`MM 6MM`MM`MM(   )P"     MM      MMYM.       ', 0x0A
db '       MM6M"   `MbMM69 " MM `MM` ,P       MM      MM YMMMMb   ', 0x0A
db '       MMMM     MMMM"    MM  `MM,P        MM      MM     `Mb  ', 0x0A
db '       MMMM     MMMM     MM   `MM.        MM      MM      MM  ', 0x0A
db ' (8)   MMMM     MMMM     MM   d`MM.       YM      M9      MM  ', 0x0A
db ' ((   ,M9YM.   ,M9MM     MM  d" `MM.       8b    d8 L    ,M9  ', 0x0A
db '  YMMMM9  YMMMMM9_MM_   _MM_d_  _)MM_       YMMMM9  MYMMMM9   ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x15
msgFancyHeader:
db '    "||"                  ||              ..|""||    .|""".|   ', 0x0A
db '     ||    ...   ... ..  ...  ... ...    .|"    ||   ||..  "   ', 0x0A
db '     ||  .|  "|.  ||" ""  ||   "|.."     ||      ||  ""|||.   ', 0x0A
db '     ||  ||   ||  ||      ||    .|.      "|.     || .     "||  ', 0x0A
db ' || .|"   "|..|" .||.    .||. .|  ||.     ""|...|"  |"....|"   ', 0x0A
db '  """                                                           ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x16
msgFancyHeader:
db '  _____                             _____   ____        ', 0x0A
db ' /\___ \                __         /\  __`\/\  _`\      ', 0x0A
db ' \/__/\ \   ___   _ __ /\_\  __    \ \ \/\ \ \,\L\_\    ', 0x0A
db '    _\ \ \ / __`\/\``__\/\ \/\ \/"  \ \ \ \ \/_\__ \    ', 0x0A
db '   /\ \_\ /\ \L\ \ \ \/ \ \ \/>  </  \ \ \_\ \/\ \L\ \  ', 0x0A
db '   \ \____\ \____/\ \_\  \ \_/\_/\_\  \ \_____\ `\____\ ', 0x0A
db '    \/___/ \/___/  \/_/   \/_\//\/_/   \/_____/\/_____/ ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x17
msgFancyHeader:
db '      ___  _______  ______    ___   __   __    _______  _______  ', 0x0A
db '     |   ||       ||    _ |  |   | |  |_|  |  |       ||       | ', 0x0A
db '     |   ||   _   ||   | ||  |   | |       |  |   _   ||  _____| ', 0x0A
db '     |   ||  | |  ||   |_||_ |   | |       |  |  | |  || |_____  ', 0x0A
db '  ___|   ||  |_|  ||    __   |   |  |     |   |  |_|  ||_____  | ', 0x0A
db ' |       ||       ||   |  |  |   | |   _   |  |       | _____| | ', 0x0A
db ' |_______||_______||___|  |_ |___| |__| |__|  |_______||_______| ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x18
msgFancyHeader:
db ' MMMMMMMM""M                   oo             MMP"""""YMM MP""""""`MM  ', 0x0A
db ' MMMMMMMM  M                                  M` .mmm. `M M  mmmmm..M  ', 0x0A
db ' MMMMMMMM  M .d8888b. 88d888b. dP dP.  .dP    M  MMMMM  M M.      `YM  ', 0x0A
db ' MMMMMMMM  M 88`  `88 88`  `88 88  `8bd8`     M  MMMMM  M MMMMMMM.  M  ', 0x0A
db ' M. `MMM` .M 88.  .88 88       88  .d88b.     M. `MMM` .M M. .MMM`  M  ', 0x0A
db ' MM.     .MM `88888P` dP       dP dP`  `dP    MMb     dMM Mb.     .dM  ', 0x0A
db ' MMMMMMMMMMM                                  MMMMMMMMMMM MMMMMMMMMMM  ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x19
msgFancyHeader:
db '        dP                   oo              .88888.  .d88888b   ', 0x0A
db '        88                                  d8"   `8b 88.    ""  ', 0x0A
db '        88 .d8888b. 88d888b. dP dP.  .dP    88     88 `Y88888b.  ', 0x0A
db '        88 88"  `88 88"  `88 88  `8bd8"     88     88       `8b  ', 0x0A
db ' 88.  .d8P 88.  .88 88       88  .d88b.     Y8.   .8P d8"   .8P  ', 0x0A
db '  `Y8888"  `88888P" dP       dP dP"  `dP     `8888P"   Y88888P   ', 0x0A
db 0x00 ; NULL byte string terminator

 %elifdef USE_FANCY_HEADER_0x55
 msgFancyHeader:
db '                                         ', 0x0A
db '                 ##                      ', 0x0A
db ' ####            ##         ####   ####  ', 0x0A
db '  ##                       ##  ## ##  #  ', 0x0A
db '  ##   ###  ## # ## ## #   ##  ## ###    ', 0x0A
db '  ##  ## ## #### ## ####   ##  ##  ###   ', 0x0A
db '  ##  ## ## ##   ##  ##    ##  ##   ###  ', 0x0A
db '  ##  ## ## ##   ## ####   ##  ## #  ##  ', 0x0A
db '  ##   ###  ##   ## # ##    ####  ####   ', 0x0A
db ' ##                                     ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x1A
msgFancyHeader:
db '        __           _         ____  _____ ', 0x0A
db '       / /___  _____(_)  __   / __ \/ ___/ ', 0x0A
db '  __  / / __ \/ ___/ / |/_/  / / / /\__ \  ', 0x0A
db ' / /_/ / /_/ / /  / />  <   / /_/ /___/ /  ', 0x0A
db ' \____/\____/_/  /_/_/|_|   \____//____/  ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x1B
msgFancyHeader:
db '  _________  ______   ______     ________  __     __       ______   ______       ', 0x0A
db ' /________/\/_____/\ /_____/\   /_______/\/__/\ /__/\     /_____/\ /_____/\      ', 0x0A
db ' \__.::.__\/\:::_ \ \\:::_ \ \  \__.::._\/\ \::\\:.\ \    \:::_ \ \\::::_\/_     ', 0x0A
db '   /_\::\ \  \:\ \ \ \\:(_) ) )_   \::\ \  \_\::_\:_\/     \:\ \ \ \\:\/___/\    ', 0x0A
db '   \:.\::\ \  \:\ \ \ \\: __ `\ \  _\::\ \__ _\/__\_\_/\    \:\ \ \ \\_::._\:\   ', 0x0A
db '    \: \  \ \  \:\_\ \ \\ \ `\ \ \/__\::\__/\\ \ \ \::\ \    \:\_\ \ \ /____\:\  ', 0x0A
db '     \_____\/   \_____\/ \_\/ \_\/\________\/ \_\/  \__\/     \_____\/ \_____\/  ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x1C
msgFancyHeader:
db '       __     ______     ______     __     __  __        ______     ______      ', 0x0A
db '      /\ \   /\  __ \   /\  == \   /\ \   /\_\_\_\      /\  __ \   /\  ___\     ', 0x0A
db '     _\_\ \  \ \ \_\ \  \ \  __<   \ \ \  \/_/\_\/_     \ \ \_\ \  \ \___  \    ', 0x0A
db '    /\_____\  \ \_____\  \ \_\ \_\  \ \_\   /\_\/\_\     \ \_____\  \/\_____\   ', 0x0A
db '    \/_____/   \/_____/   \/_/ /_/   \/_/   \/_/\/_/      \/_____/   \/_____/   ', 0x0A
db '                                                                                ', 0x0A
db '   /--------------------------------------------------------------------------\ ', 0x0A
db '   \--------------------------------------------------------------------------/ ', 0x0A

db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x1D
msgFancyHeader:
db ' _________            _____          _______________ ', 0x0A
db ' ______  ________________(_____  __  __  __ __  ___/ ', 0x0A
db ' ___ _  /_  __ __  _____  /__  |/_   _  / / _____ \  ', 0x0A
db ' / /_/ / / /_/ _  /   _  / __>  <    / /_/ /____/ /  ', 0x0A
db ' \____/  \____//_/    /_/  /_/|_     \____/ /____/   ', 0x0A
db '                                               ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x1E
msgFancyHeader:
db '     __         _      _____ _____  ', 0x0A
db '  __|  |___ ___|_|_ _ |     |   __| ', 0x0A
db ' |  |  | . |  _| |_"_ |  |  |__   | ', 0x0A
db ' |_____|___|_| |_|_,_ |_____|_____| ', 0x0A
db '                                    ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x1F
msgFancyHeader:
db ' ============================================================== ', 0x0A
db ' =====    ====================================    =====      == ', 0x0A
db ' ======  ====================================  ==  ===  ====  = ', 0x0A
db ' ======  ===================================  ====  ==  ====  = ', 0x0A
db ' ======  ====   ===  =   ===  ==  =  =======  ====  ===  ====== ', 0x0A
db ' ======  ===     ==    =  ======  =  =======  ====  =====  ==== ', 0x0A
db ' ======  ===  =  ==  =======  ===   ========  ====  =======  == ', 0x0A
db ' =  ===  ===  =  ==  =======  ===   ========  ====  ==  ====  = ', 0x0A
db ' =  ===  ===  =  ==  =======  ==  =  ========  ==  ===  ====  = ', 0x0A
db ' ==     =====   ===  =======  ==  =  =========    =====      == ', 0x0A
db ' ============================================================== ', 0x0A
db 0x00 ; NULL byte string terminator

%elifdef USE_FANCY_HEADER_0x20
msgFancyHeader:
db ' _____ooo_______________oo_____________oooo____ooooo__ ', 0x0A
db ' ______oo_ooooo_oo_ooo_____o____o____oo____oo_oo___oo_ ', 0x0A
db ' ______oooo___ooooo___o_oo__oo_o____oo______oo_oo_____ ', 0x0A
db ' oo____oooo___oooo______oo___oo_____oo______oo___oo___ ', 0x0A
db ' oo____oooo___oooo______oo__o_oo_____oo____oo_oo___oo_ ', 0x0A
db ' _ooooo___ooooo_oo_____ooooo___oo______oooo____ooooo__ ', 0x0A
db ' _____________________________________________________ ', 0x0A

db 0x00 ; NULL byte string terminator.
%endif ; USE_FANCY_HEADER_0x??

%endif ; FANCY_HEADER_ASM_INCLUDED

