package com.maestrodev;

import org.schwering.irc.lib.IRCConnection;

/**
 * Maestro Irc plugin to send messages to IRC channels.
 * 
 */
public class IrcWorker extends MaestroWorker {

    public IrcWorker() {
        super();
    }

    public void postMessage() throws Exception {
        try{
           
            String host = getField("host");
            if(host == null){
                writeOutput("[WARNING] Field 'Server' Is Deprecated\n");
                host = getField("server");
            }
            
            final IRCConnection conn = new IRCConnection(
                    host,
                    Integer.parseInt(getField("port").toString()),
                    Integer.parseInt(getField("port").toString()) + 2,
                    null,
                    getField("nickname"),
                    getField("nickname"),
                    getField("nickname"));
            
           
            
            IrcEventListener eventListener = new IrcEventListener(conn, getField("channel"), getField("body"), this);
            conn.addIRCEventListener(eventListener);
            conn.setDaemon(true);
            conn.setColors(false);
            conn.setPong(true);

           
            conn.connect(); // Try to connect!!! Don't forget this!!!
            

           
            
            while (!eventListener.wasMessageSent() && !eventListener.wasError()) {
                Thread.sleep(1000);
            }
            
            if(eventListener.wasError()){
                conn.doQuit();
                throw new Exception(eventListener.getError());
            }
            
            
            //writeOutput("The Message Was Sent!");

            while (conn.isConnected()) {
                
                conn.doQuit();
                Thread.sleep(5000);
            }
            
            writeOutput("Message " + getField("body") + " Sent");
            
        } catch (Exception e) {
            if (!Boolean.parseBoolean(this.getField("ignore_failure"))) {
                setError("Error Posting Message " + e.getMessage());
                throw e;
            } else {
                this.writeOutput("Error Posting Message " + e.getMessage());
                this.writeOutput("\nIgnore Flag Is True, Composition Will Continue");
            }
        }
    }
}
