package com.maestrodev;

import static org.junit.Assert.*;

import java.util.Arrays;

import org.json.simple.JSONObject;
import org.junit.Test;

import com.maestrodev.maestro.plugin.Manifest;

/**
 * Unit test for the Irc worker
 */
@SuppressWarnings("unchecked")
public class IrcWorkerTest {

    private JSONObject defaultFields() {
        JSONObject fields = new JSONObject();
        fields.put("body", "Hello From Maestro 4!\rGoodbye from Maestro4\nI am lost...");
        fields.put("nickname", "irc-plugin-test");
        fields.put("host", "irc.freenode.net");
        fields.put("password", "");
        fields.put("ssl", "false");
        fields.put("port", "6667");
        fields.put("channel", "#maestrodev");
        fields.put("ignore_failure", "false");
        return fields;
    }

    @Test
    public void validateManifest() throws Exception {
        Manifest manifest = new Manifest(this.getClass().getClassLoader().getResourceAsStream("manifest.json"));
        manifest.validate();
        assertTrue(Arrays.toString(manifest.getErrors().toArray()), manifest.isValid());
        assertEquals(1, manifest.getPlugins().size());
    }

    @Test
    public void testPostMessage() throws Exception {
        IrcWorker ircWorker = new IrcWorker();
        JSONObject fields = defaultFields();
        JSONObject workitem = new JSONObject();
        workitem.put("fields", fields);
        ircWorker.setWorkitem(workitem);
        ircWorker.postMessage();

        assertNull(ircWorker.getError(), ircWorker.getError());
    }

    @Test
    public void testIgnoreFailureOnFailure() throws Exception {

        IrcWorker ircWorker = new IrcWorker();
        JSONObject fields = defaultFields();
        fields.put("host", "not.real.com");
        fields.put("ignore_failure", "true");

        JSONObject workitem = new JSONObject();
        workitem.put("fields", fields);
        ircWorker.setWorkitem(workitem);
        ircWorker.postMessage();

        assertNull(ircWorker.getError(), ircWorker.getError());
    }

    @Test
    public void testDontIgnoreFailureOnFailure() throws Exception {

        IrcWorker ircWorker = new IrcWorker();
        JSONObject fields = defaultFields();
        fields.put("host", "not.real.com");

        JSONObject workitem = new JSONObject();
        workitem.put("fields", fields);
        ircWorker.setWorkitem(workitem);

        try {
            ircWorker.postMessage();
            fail("Exception should be thrown");
        } catch (Exception e) {

        }

        assertEquals("Error Posting Message not.real.com", ircWorker.getError());
    }
}
