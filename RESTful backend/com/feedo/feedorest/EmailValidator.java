package com.feedo.feedorest;

import java.util.regex.Pattern;

public class EmailValidator {
    //Based on https://www.rfc-editor.org/info/rfc5322
    private static final String regexPattern = "^[a-zA-Z0-9_!#$%&'*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+$";

    public static boolean validate(String emailAddress) {
        return Pattern.compile(regexPattern)
                .matcher(emailAddress)
                .matches();
    }
}

