package com.maestrodev;

import org.schwering.irc.lib.IRCConnection;

/**
  * Hello world!
    *
      */
        public class IrcWorker extends MaestroWorker
{
  public IrcWorker(){     
    super();
  }
    
  public void postMessage() throws Exception {
        
    final IRCConnection conn = new IRCConnection(
      getField("server"), 
        Integer.parseInt(getField("port").toString()),
          Integer.parseInt(getField("port").toString()) + 1, 
            null, 
              getField("nickname"), 
                getField("nickname"), 
                  getField("nickname")
                    ); 
		    
    IrcEventListener eventListener = new IrcEventListener(conn, getField("channel"), getField("body"));
    conn.addIRCEventListener(eventListener);
    conn.setDaemon(true);
    conn.setColors(false); 
    conn.setPong(true); 
         
    try {
      conn.connect(); // Try to connect!!! Don't forget this!!!
    } catch (Exception ioexc) {
      ioexc.printStackTrace(); 
    }

         
    while(!eventListener.wasMessageSent()){         
      Thread.sleep(1000);
    }
         
    //writeOutput("The Message Was Sent!");
         
    conn.close();
  }
      
}