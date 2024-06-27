package com.feedo.feedorest;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;


@Path("/test")
public class TestResource {

    @Path("/")
    @POST
    @Produces(MediaType.TEXT_PLAIN)
    public String doTestPost() {
        return "It works!";
    }

    @Path("/")
    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String doTestGet() {
        return "It works!";
    }

}