package com.maestrodev;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import org.json.simple.JSONObject;

/**
 * Unit test for simple App.
 */
public class IrcWorkerTest 
    extends TestCase
{
    /**
     * Create the test case
     *
     * @param testName name of the test case
     */
    public IrcWorkerTest( String testName )
    {
        super( testName );
    }

    /**
     * @return the suite of tests being tested
     */
    public static Test suite()
    {
        return new TestSuite( IrcWorkerTest.class );
    }
//     {"body" : {"value" : "", "type" : "String", "required" : "true"},
//		"nickname":{"value" : "", "type" : "String", "required" : "true"},
//		"server":{"value" : "", "type" : "String", "required" : "true"},
//		"password":{"value" : "", "type" : "Password", "required" : "false"},
//		"ssl":{"value" : "", "type" : "Boolean", "required" : "true"},
//		"port":{"value" : "", "type" : "Integer", "required" : "true"},
//		"channel":{"value" : "", "type" : "String", "required" : "true"}

    /**
     * Test IrcWorker
     */
    public void testIrcWorker() throws NoSuchMethodException, IllegalAccessException, IllegalArgumentException, InvocationTargetException
    {
        IrcWorker ircWorker = new IrcWorker();
        JSONObject fields = new JSONObject();
        fields.put("body", "Hello From Javaland!");
        fields.put("nickname", "irc-plugin-test");        
        fields.put("server", "irc.freenode.net");
        fields.put("password", null);
        fields.put("ssl", "false");
        fields.put("port", "6667");
        fields.put("channel", "#kittest");        
        
        JSONObject workitem = new JSONObject();
        workitem.put("fields", fields);
        ircWorker.setWorkitem(workitem);
               
        
        for(Object key : ircWorker.getWorkitem().keySet()){
            System.out.println(key);
        }
        
        Method method = ircWorker.getClass().getMethod("postMessage");
        method.invoke(ircWorker);
        
    }
}
