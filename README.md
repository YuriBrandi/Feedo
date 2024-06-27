# Feedo:

### A cloud-based, open-source, ecosystem for food dispensing via IoT devices.

<p align='center'> 
    <img src=https://github.com/YuriBrandi/Feedo/assets/52039988/80904478-2264-4ffd-9d1b-e01d45a09f14 width=250>
</p>

This University work consists of a sophisticated Azure-based architecture for administrating IoT devices across the Internet, powered by a JAX - RS RESTful back-end and a platform agnostic Flutter-based client.![Uploading feedo_logo_circle.svg…]()


### Author(s)
[@YuriBrandi](https://github.com/YuriBrandi).

## Fido
<img src=https://github.com/YuriBrandi/Feedo/assets/52039988/2f41feca-50d7-4e9a-8961-d4bff8d59d86 width=300>

Photo credits: Bruno Pollacci

[About Fido](https://en.wikipedia.org/wiki/Fido_(Italian_dog))

## Architecture

<p align='center'> 
    <img src=https://github.com/YuriBrandi/Feedo/assets/52039988/f3c08e23-b741-4b24-97da-d47975f6215a width=750>
</p>


The architecture might look overwhelming at first sight, but breaking it down from the different actor's perspectives makes it extremely simple.

#### Users
The *Users* connect via Flutter-based clients to the RESTful Web Service, available through a public IP exposed to the Internet. Once authenticated through the *Email Communication Service*, they can set timers stored on the *IoT Hub*, which will eventually trigger the IoT devices' action to feed their pets.

#### Administrators
The *Administrators* can manage the *MySQL DB* **only** by connecting to an *Azure Bastion* by using the private key stored in the *Key Vault*, the connection occurs either natively via SSH or through the *Azure Portal* (TLS). The bastion uses an SSH connection to display a VM which similarly to the MySQL DB, is **unexposed** to the Internet. 

*Alerts* for HTTP errors occurring in the back-end are sent via SMS/email to the Administrator(s).

The back-end is deployed through *OneDeploy* pushes while the front-end by *CI/CD* integration in Git repositories.

## Device Twins

To make sending data to IoT devices simple without involving [Hub Endpoints](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-endpoints) or [Message routing](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-messages-d2c) can be simply yet extremely elegantly done by using [Device Twins](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-device-twins).

Device twins allow for properties to be read and written both by a back-end and by an IoT device.

The former stores **desired properties**, which represent a state desired by the back-end and reads the properties reported by the IoT device (i.e. **reported properties**).

The IoT device acknowledges the properties desired by the back-end and reports its current properties.

## RESTful API
The API is documented via OpenAPI [here](#) and consists of three paths:

1. *.../api/users*
2. *.../api/devices*
3. *.../api/test*

These first is used to create, delete, authenticate, reset users by using POST HTTPS requests.

These second is used to set and retrieve timers, specifically to get the latest triggered timer *(i.e. reported timer property)* of a time, and the next timer *(i.e. desired timer property)*.

## Installation and usage
A web client, an Android App Bundle *(.aab)* and a Linux native client are readily available.

To replicate the architecture by using the provided examples please refer to:

- [Microsoft Learn](https://learn.microsoft.com/en-us/azure)

For more information regarding the employed technologies please refer to:

- [Flutter Docs](https://docs.flutter.dev/)
- [JAX - RS article](https://www.oracle.com/technical-resources/articles/java/jax-rs.html)

The API is documented via OpenAPI [here](#).

## Contributions

Contributions are very much appreciated. Please well describe your changes inside your PR to make it easier to understand them.

If you encounter any problem or bug that is unrelated with your own machine, please report it and *open a new issue* with replicable steps. 

## License

This project is distributed under the [GNU General Public License v3](LICENSE).

![GPLv3Logo](https://www.gnu.org/graphics/gplv3-127x51.png)
