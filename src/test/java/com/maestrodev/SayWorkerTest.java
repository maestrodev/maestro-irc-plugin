package com.maestrodev;

import java.lang.reflect.InvocationTargetException;
import java.util.Map;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import org.json.simple.JSONObject;
import org.json.simple.parser.ParseException;

/**
 * Unit test for simple App.
 */
public class SayWorkerTest 
    extends TestCase
{
    /**
     * Create the test case
     *
     * @param testName name of the test case
     */
    public SayWorkerTest( String testName )
    {
        super( testName );
    }

    /**
     * @return the suite of tests being tested
     */
    public static Test suite()
    {
        return new TestSuite( SayWorkerTest.class );
    }


    /**
     * Test SayWorker
     */
    public void testSayWorker() throws NoSuchMethodException, IllegalAccessException, IllegalArgumentException, InvocationTargetException, ParseException
    {
        SayWorker sayWorker = new SayWorker();
        JSONObject fields = new JSONObject();
        fields.put("body", "Hello From Javaland!");
        
        JSONObject workitem = new JSONObject();
        workitem.put("fields", fields);
        sayWorker.setWorkitem(workitem);

        workitem = (JSONObject) sayWorker.perform("say", workitem);
        
        assertNull(((Map)workitem.get("fields")).get("__error__"));
        
    }
}
