package com.feedo.feedorest;

import com.azure.communication.email.models.EmailMessage;

import com.feedo.feedorest.dao.UserDAO;
import com.feedo.feedorest.model.User;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;


@Path("/users")
public class UsersResource {

    @Inject
    private AzureEmailClient azureEmailClient;

    @Path("/do-login")
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public String doLogin(String val) {
        System.out.println(val);

        if(val.isEmpty()){
            System.out.println("Empty values");
            return "{}";
        }

        User usr;
        try{
            usr = new User(val);
        }
        catch (IllegalArgumentException e){
            System.out.println("Invalid format");
            return "{}";
        }

        UserDAO usrDao = new UserDAO();

        User resUser =  usrDao.doLogin(usr);
        return resUser != null ? resUser.toJSON() : "{}";
    }

    @Path("/do-signup")
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.TEXT_PLAIN)
    public String doSignup(String val) {
        System.out.println(val);

        if(val.isEmpty()){
            System.out.println("Empty values");
            return "empty_values";
        }

        User usr;
        try{
            usr = new User(val);
        }
        catch (IllegalArgumentException e){
            System.out.println("Invalid format");
            return "invalid_format";
        }

        if(!EmailValidator.validate(usr.getEmail()))
            return "invalid_email";

        UserDAO usrDao = new UserDAO();

        if(usrDao.doVerify(usr))
            return "duplicate";

        usr.setPassword(RandomPasswordGenerator.generateRandomPassword(12));

        if(usrDao.doSignup(usr) == 1){

            EmailMessage message = new EmailMessage()
                    .setSenderAddress("<DoNotReply@abc.azurecomm.net>")
                    .setToRecipients("<" + usr.getEmail() + ">")
                    .setSubject("Feedo Account Created")
                    .setBodyPlainText("The password for your account is: " + usr.getPassword() + "\n" +
                            "Please store it carefully.");

            azureEmailClient.sendAsyncMail(message);

            return "ok";

        }

        return "error";
    }

    @Path("/do-delete")
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.TEXT_PLAIN)
    public String doDelete(String val) {
        System.out.println(val);

        if(val.isEmpty()){
            System.out.println("Empty values");
            return "empty_values";
        }

        User usr;
        try{
            usr = new User(val);
        }
        catch (IllegalArgumentException e){
            System.out.println("Invalid format");
            return "invalid_format";
        }

        UserDAO usrDao = new UserDAO();

        if(usrDao.doDelete(usr) == 1)
            return "done";

        return "error";
    }

    @Path("/do-recover")
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.TEXT_PLAIN)
    public String doRecover(String val) {
        System.out.println(val);

        if(val.isEmpty()){
            System.out.println("Empty values");
            return "empty_values";
        }

        User usr;
        try{
            usr = new User(val);
        }
        catch (IllegalArgumentException e){
            System.out.println("Invalid format");
            return "invalid_format";
        }

        UserDAO usrDao = new UserDAO();

        if(!usrDao.doVerify(usr))
            return "error_mail";

        usr.setPassword(RandomPasswordGenerator.generateRandomPassword(12));

        if(usrDao.doPasswordReset(usr) == 1){
            EmailMessage message = new EmailMessage()
                    .setSenderAddress("<DoNotReply@abc.azurecomm.net>")
                    .setToRecipients("<" + usr.getEmail() + ">")
                    .setSubject("Feedo Password Reset")
                    .setBodyPlainText("Your password has been reset. Your new password is: " + usr.getPassword() + "\n" +
                            "Please store it carefully.");

            azureEmailClient.sendAsyncMail(message);

            return "done";

        }

        return "error";
    }


}
