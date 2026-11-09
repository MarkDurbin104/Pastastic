

                        Functional Specification.

                       DDI10 Screen Device Driver.


                     Date            10th August 1990.
                     Author          Paul Encarnacion.
                     

                      Copyright (c) 1990 Unisys Corp.

        The primary requirements for the DDI10.SYS video device driver 
        are:

        1. Switch the video mode to 80 column MONO (hercules) mode.
        2. Switch the video mode to 40 column CGA mode.
        3. Switch the video mode to 80 column CGA mode.
        4. Use a 60Hz refresh rate with 80 column MONO and 40 column 
           CGA modes.

        The DDI10.SYS driver should implement 'clean' switching between
        CGA and HERCULES screen modes under the PC-MOS environment.

        As PC-MOS assumes that the video card will not change after boot up
        and the Unisys Magic-combo card offers both the CGA and HERCULES
        video facilities.  PC-MOS will need to be 'told' when the video mode
        has been changed.

        This can be achieved by chaining into the interrupt 10h call,
        checking if the call is a video mode switch and 'telling' PC-MOS 
        if it is.

        Programs will be provided to switch to 80 column MONO mode
        and 40 column CGA mode via the DDI10.SYS driver. 

        PC-MOS will be informed by writing directly to the variables
        (within the PC-MOS kernel) that set the screen type and base 
        address.  There are only global (ie not task specific)
        video hardware variables within PC-MOS.  
        
        Switching video modes when there are two or more tasks active will 
        not catered for.  At best, PAM switching will be disabled or handled 
        with care if the video mode is switched when two or more tasks are 
        active.

        Because these variables are merely patch addresses within PC-MOS
        the DDI10.SYS driver will be PC-MOS version specific.

        DDI10.SYS will be PC-MOS version 4.10 specific.

