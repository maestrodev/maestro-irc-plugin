package com.maestrodev;

import java.io.IOException;
import org.schwering.irc.lib.IRCConnection;
import org.schwering.irc.lib.IRCEventListener;
import org.schwering.irc.lib.IRCModeParser;
import org.schwering.irc.lib.IRCUser;

/**
 * Hello world!
 *
 */
public class IrcWorker extends MaestroWorker
{
    
    private boolean messageSent;
    
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
         conn.addIRCEventListener(new IrcEventListener(conn));
         conn.setDaemon(true);
         conn.setColors(false); 
         conn.setPong(true); 
         
//         new Thread(){
//         public void run(){
             try {
               conn.connect(); // Try to connect!!! Don't forget this!!!
               messageSent = false;               
             } catch (Exception ioexc) {
               ioexc.printStackTrace(); 
             }
//            }
//         }.start();
         
         while(!messageSent){
            Thread.sleep(5000);
         }
         conn.close();
    }    
    
    private class IrcEventListener implements IRCEventListener {

        private IRCConnection connection;
        
        public IrcEventListener(IRCConnection connection){
            this.connection = connection;
        }
            
        public void onRegistered() {
            System.err.println("connected");
            this.connection.doJoin(getField("channel"));
        }

        public void onDisconnected() {
            
        }

        public void onError(String string) {
            
        }

        public void onError(int i, String string) {
            
        }

        public void onInvite(String string, IRCUser ircu, String string1) {
            
        }

        public void onJoin(String string, IRCUser ircu) {
            System.out.println("Joined " + string);
            this.connection.doPrivmsg(getField("channel"), getField("body"));
            messageSent = true;
        }

        public void onKick(String string, IRCUser ircu, String string1, String string2) {
           
        }

        public void onMode(String string, IRCUser ircu, IRCModeParser ircmp) {
           
        }

        public void onMode(IRCUser ircu, String string, String string1) {
           
        }

        public void onNick(IRCUser ircu, String string) {
           
        }

        public void onNotice(String string, IRCUser ircu, String string1) {
           
        }

        public void onPart(String string, IRCUser ircu, String string1) {
           
        }

        public void onPing(String string) {
           
        }

        public void onPrivmsg(String string, IRCUser ircu, String string1) {
           
        }

        public void onQuit(IRCUser ircu, String string) {
           
        }

        public void onReply(int i, String string, String string1) {
           
        }

        public void onTopic(String string, IRCUser ircu, String string1) {
           
        }

        public void unknown(String string, String string1, String string2, String string3) {
           
        }
        
    }
  
}


    
            

