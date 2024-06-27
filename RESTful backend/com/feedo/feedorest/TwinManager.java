package com.feedo.feedorest;

import com.microsoft.azure.sdk.iot.service.devicetwin.*;
import com.microsoft.azure.sdk.iot.service.exceptions.IotHubException;

import java.io.IOException;
import java.util.Set;

public class TwinManager
{
    //Connect with Shared Access with special policy name.
    public static final String iotHubConnectionString = "";
    public static final String deviceId = "device_name";

    public static boolean updateTimer(long TimeToFeed){
        // Get the DeviceTwin and DeviceTwinDevice objects
        try {
            DeviceTwin twinClient = DeviceTwin.createFromConnectionString(iotHubConnectionString);

            DeviceTwinDevice device = new DeviceTwinDevice(deviceId);

            System.out.println("Device twin before update:");
            twinClient.getTwin(device);
            System.out.println(device);

            //Change desired device properties
            Set<Pair> properties = device.getDesiredProperties();

            for(Pair pair : properties){
                if(pair.getKey().equals("TimeToFeed")){
                    pair.setValue(TimeToFeed);
                }
            }

            device.setDesiredProperties(properties);

            // Update the device twin in IoT Hub
            System.out.println("Updating device twin");
            twinClient.updateTwin(device);

            return true;

        } catch (IOException e) {
            System.out.println("Unable to connect to IotHub.");
            throw new RuntimeException(e);
        } catch (IotHubException e) {
            System.out.println("Unable to update IoTHub properties.");
            throw new RuntimeException(e);
        }


    }

    public static String getLastFed(){
        // Get the DeviceTwin and DeviceTwinDevice objects
        try {
            DeviceTwin twinClient = DeviceTwin.createFromConnectionString(iotHubConnectionString);

            DeviceTwinDevice device = new DeviceTwinDevice(deviceId);

            System.out.println("Device twin:");
            twinClient.getTwin(device);
            System.out.println(device);

            Set<Pair> properties = device.getReportedProperties();

            String value = "";
            for(Pair pair : properties){
                if(pair.getKey().equals("LastTimeFed")){
                    value = String.valueOf((long) Double.parseDouble(pair.getValue().toString()));
                }
            }

            return value;


        } catch (IOException e) {
            System.out.println("Unable to connect to IotHub.");
            throw new RuntimeException(e);
        } catch (IotHubException e) {
            System.out.println("Unable to update IoTHub properties.");
            throw new RuntimeException(e);
        }


    }

    public static String getTimer(){
        // Get the DeviceTwin and DeviceTwinDevice objects
        try {
            DeviceTwin twinClient = DeviceTwin.createFromConnectionString(iotHubConnectionString);

            DeviceTwinDevice device = new DeviceTwinDevice(deviceId);

            System.out.println("Device twin:");
            twinClient.getTwin(device);
            System.out.println(device);

            Set<Pair> properties = device.getDesiredProperties();

            String value = "";
            for(Pair pair : properties){
                if(pair.getKey().equals("TimeToFeed")){
                    value = String.valueOf((long) Double.parseDouble(pair.getValue().toString()));
                }
            }

            return value;


        } catch (IOException e) {
            System.out.println("Unable to connect to IotHub.");
            throw new RuntimeException(e);
        } catch (IotHubException e) {
            System.out.println("Unable to update IoTHub properties.");
            throw new RuntimeException(e);
        }


    }

}
