package com.cms.websocket;

import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Collections;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint("/ws/notifications/{role}/{userId}")
public class NotificationServer {
    
    // Map of role -> Set of sessions
    private static final Map<String, Set<Session>> roleSessions = new ConcurrentHashMap<>();
    
    // Map of userId -> Set of sessions
    private static final Map<String, Set<Session>> userSessions = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session, @PathParam("role") String role, @PathParam("userId") String userId) {
        roleSessions.computeIfAbsent(role, k -> Collections.newSetFromMap(new ConcurrentHashMap<>())).add(session);
        userSessions.computeIfAbsent(userId, k -> Collections.newSetFromMap(new ConcurrentHashMap<>())).add(session);
    }

    @OnClose
    public void onClose(Session session, @PathParam("role") String role, @PathParam("userId") String userId) {
        if (roleSessions.containsKey(role)) roleSessions.get(role).remove(session);
        if (userSessions.containsKey(userId)) userSessions.get(userId).remove(session);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        // Not accepting messages from client
    }

    public static void sendToUser(String userId, String message) {
        Set<Session> sessions = userSessions.get(userId);
        if (sessions != null) {
            for (Session s : sessions) {
                if (s.isOpen()) {
                    try {
                        s.getBasicRemote().sendText(message);
                    } catch (IOException e) { e.printStackTrace(); }
                }
            }
        }
    }

    public static void sendToRole(String role, String message) {
        Set<Session> sessions = roleSessions.get(role);
        if (sessions != null) {
            for (Session s : sessions) {
                if (s.isOpen()) {
                    try {
                        s.getBasicRemote().sendText(message);
                    } catch (IOException e) { e.printStackTrace(); }
                }
            }
        }
    }
}
