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
    private boolean messageReceived; 
    private String message;
    private String body[], channel;
    private MaestroWorker worker;
    private boolean wasError;
    private String errorMessage;
    
    
    public IrcEventListener(IRCConnection connection,
            String channel,
            String body) {
        this.connection = connection;
        this.body = body.split("[\n\r]");
        this.channel = channel;
    }

    public IrcEventListener(IRCConnection connection,
            String channel,
            String body,
            MaestroWorker worker) {
        this.connection = connection;
        this.body = body.split("[\n\r]");
        this.channel = channel;
        this.worker = worker;
    }
    
    public synchronized boolean wasMessageSent() {
        return messageSent;
    }

    
    public boolean wasMessageReceived() {
        return messageReceived;
    }
    
    public String getMessage() {
        messageReceived = false;
        return message;
    }
    
    public void onRegistered() {
            
        connection.doJoin(channel);
        messageSent = false;
    }
    
    public void putMessage(String message){
        connection.doPrivmsg(channel, message);
    }

    public void onDisconnected() {
        
    }

    public void onError(String string) {
        
        this.wasError = true;
        this.errorMessage = string;
    }

    public void onError(int i, String string) {
                
        this.wasError = true;
        this.errorMessage = string;
    }

    public void onInvite(String string, IRCUser ircu, String string1) {
    }

    public void onJoin(String string, IRCUser ircu) {
            
        for (String line : body) {
            putMessage(line);
        }
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

    public void onPrivmsg(String channel, IRCUser ircu, String message) {
        this.message = message;
        this.messageReceived = true;
    }

    public void onQuit(IRCUser ircu, String string) {
    }

    public void onReply(int i, String string, String string1) {
    }

    public void onTopic(String string, IRCUser ircu, String string1) {
    }

    public void unknown(String string, String string1, String string2, String string3) {
    }

    boolean wasError() {
        return this.wasError;
    }

    String getError() {
        return this.errorMessage;
    }

}