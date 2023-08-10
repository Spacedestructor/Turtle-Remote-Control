# Turtle-Remote-Control
 Lets you Remote Control Minecraft Turtles, Computers and Pocket Computers from the ComputerCraft/ComputerCraft Tweaked Mod.
 If the Device is a turtle Filename will be "TurtleRemoteControl.lua", if its a Computer it will be "ComputerRemoteControl.lua", for Pocket Computers is "PocketRemoteControl.lua"
 For singleplayer worlds its in the save folder of the coresponding world, computercraft and then depending on the device you want to put it on its either "computer" or "disk".
 Inside these folders devices are listed by there ID, you drop the File you want to use in there and it will show up on the device.
 No idea how this works for Multiplayer, helps if you go on the device and create the File your self with a random text, save it, get the device id from the terminal with the command "id". then go find the worlds folder for the multiplayer game and the rest will probably be similar like it is with singleplayer.
 This should apply to any places where you created the file on the folder as the mod should just mimic the folder path on your pc, so if its not in the root Location, just go in to whatever folder you created it in.
You can run the script by navigating on the Device where the File is stored and press run.
After this it should only require your attention if an error occures, it looses connection or for any other reason may stop responding to the websocket.
In those cases simply just reboot and execute the script again.
