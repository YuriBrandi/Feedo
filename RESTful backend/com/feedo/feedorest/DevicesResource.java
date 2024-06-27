package com.feedo.feedorest;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;


@Path("/devices")
public class DevicesResource {

    @Path("/getLastFed")
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.TEXT_PLAIN)
    public String getLastFed(String val) {
       UsersResource userResource = new UsersResource();
       String res = userResource.doLogin(val);

       if(res.equals("{}"))
           return "auth_failed";
       else {
           return TwinManager.getLastFed();
       }
    }

    @Path("/getTimer")
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.TEXT_PLAIN)
    public String getTimer(String val) {
        UsersResource userResource = new UsersResource();
        String res = userResource.doLogin(val);

        if(res.equals("{}"))
            return "auth_failed";
        else {
            return TwinManager.getTimer();
        }
    }

    @Path("/do-updateTimer")
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.TEXT_PLAIN)
    public String doUpdateTimer(String val) {
        JsonObject jsonObject = JsonParser.parseString(val).getAsJsonObject();
        if(!jsonObject.has("timerValue"))
            return "missing_property_timerValue";

        long timerValue;
        try{
             timerValue = jsonObject.get("timerValue").getAsLong();
        }
        catch (NumberFormatException e){
            return "invalid_timerValue";
        }

        System.out.println("Extracted new_value: " + timerValue);

        jsonObject.remove("timerValue");

        UsersResource userResource = new UsersResource();
        String res = userResource.doLogin(jsonObject.toString());

        if(res.equals("{}"))
            return "auth_failed";
        else {
            return TwinManager.updateTimer(timerValue) ? "success" : "failed";
        }
    }

}
