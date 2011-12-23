/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.maestrodev;

import com.sun.speech.freetts.Voice;
import com.sun.speech.freetts.VoiceManager;

/**
 *
 * @author kelly
 */
public class SayWorker extends MaestroWorker {

    String voiceName = "kevin16";
    VoiceManager voiceManager;
    Voice voice;

    public SayWorker() {
        super();
        setup();
    }

    public void say() {
        String words = getField("body");
        if (words == null) {
            words = "nothing";
        }
        voice.speak(words);

    }
    
    
    private void listAllVoices() {
        System.out.println();
        System.out.println("All voices available:");
        VoiceManager voiceManager = VoiceManager.getInstance();
        Voice[] voices = voiceManager.getVoices();
        
        for (int i = 0; i < voices.length; i++) {
            System.out.println("    " + voices[i].getName()
                    + " (" + voices[i].getDomain() + " domain)");
        }
    }

    private void setup() {

        System.out.println("Using voice: " + voiceName);

        voiceManager = VoiceManager.getInstance();
        voice = voiceManager.getVoice(voiceName);

        voice.setPitch(1.75f);
        voice.setPitchShift(0.75f);
        // voice.setPitchRange(10.1); //mutace
        voice.setStyle("casual");  //"business", "casual", "robotic", "breathy"

        if (voice == null) {
            System.err.println(
                    "Cannot find a voice named "
                    + voiceName + ".  Please specify a different voice.");
            System.exit(1);
        }
        voice.allocate();
    }


}
