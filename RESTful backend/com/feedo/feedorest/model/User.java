package com.feedo.feedorest.model;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

public class User {
    private String email, name, surname, password;

    public User(){

    }

    public User(String email, String name, String surname, String password) {
        this.email = email;
        this.name = name;
        this.surname = surname;
        this.password = password;
    }

    public User(String JSON) throws IllegalArgumentException {
        Gson gson = new Gson();
        User user = gson.fromJson(JSON, User.class);

        if(user != null) {
            this.email = user.email;
            this.name = user.name;
            this.surname = user.surname;
            this.password = user.password;
        }
        else
            throw new IllegalArgumentException("Invalid user JSON format");
    }
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSurname() {
        return surname;
    }

    public void setSurname(String surname) {
        this.surname = surname;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Override
    public String toString() {
        return "User{" +
                "email='" + email + '\'' +
                ", name='" + name + '\'' +
                ", surname='" + surname + '\'' +
                ", password='" + password + '\'' +
                '}';
    }

    public String toJSON() {
        Gson gson = new Gson();
        return gson.toJson(this);
    }
}
