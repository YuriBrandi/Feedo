package com.feedo.feedorest;

import com.azure.communication.email.EmailAsyncClient;
import com.azure.communication.email.EmailClientBuilder;

import com.azure.communication.email.models.EmailMessage;
import com.azure.communication.email.models.EmailSendResult;
import com.azure.core.util.polling.LongRunningOperationStatus;
import com.azure.core.util.polling.PollerFlux;

import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Named;


@Named
@ApplicationScoped
public class AzureEmailClient {
    private EmailAsyncClient emailClient;

    @PostConstruct
    public void init() {
        String connectionString = "";
        emailClient = new EmailClientBuilder()
                .connectionString(connectionString)
                .buildAsyncClient();
    }

    public EmailAsyncClient getEmailClient() {
        return emailClient;
    }

    public void sendAsyncMail(EmailMessage emailMessage){
        PollerFlux<EmailSendResult, EmailSendResult> poller = getEmailClient().beginSend(emailMessage);
        // The initial request is sent out as soon as we subscribe the to PollerFlux object
        poller.subscribe(
                response -> {
                    if (response.getStatus() == LongRunningOperationStatus.SUCCESSFULLY_COMPLETED) {
                        System.out.printf("Successfully sent the email (operation id: %s)", response.getValue().getId());
                    }
                    else {
                        System.out.println("Email send status: " + response.getStatus());
                    }
                },
                error -> {
                    System.out.println("Error occurred while sending email: " + error.getMessage());
                }
        );

    }
}
