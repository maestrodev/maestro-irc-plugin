/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.maestrodev;

import org.schwering.irc.lib.IRCConnection;
import org.schwering.irc.lib.IRCEventListener;
import org.schwering.irc.lib.IRCModeParser;
import org.schwering.irc.lib.IRCUser;

class IrcEventListener implements IRCEventListener {

        
        private IRCConnection connection;
        private boolean messageSent;
        private String body, channel;
        
        
        public IrcEventListener(IRCConnection connection, String channel, String body){
            this.connection = connection;
            this.body = body;
            this.channel = channel;
        }
            
        public synchronized boolean wasMessageSent(){
            return messageSent;
        }
        
        public void onRegistered() {
            connection.doJoin(channel);
            messageSent = false;
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
            connection.doPrivmsg(channel, body);
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