##Package the application

adt -package -keystore newcert1.p12 -storetype pkcs12 -target bundle metas Scratch-app.xml Scratch.swf asset locale medialibraries

##Debug and run the scratch

adl Scratch-app.xml

Note:

###Create a Certificate

adt -certificate -cn "Jimmy Hui/emailAddress=jimmy@coding101.hk" 2048-RSA newcert1.p12 <password>