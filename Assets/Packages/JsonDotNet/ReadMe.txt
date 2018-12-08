Thank you for supporting my asset development.  Here are some notes to get you started using JSON .NET

**IMPORTANT** If you are upgrading from a version prior to 1.3.0 you will need to delete the old asset folder.  
Prior to version 1.3.0 the root folder was "DustinHorne".  I have simplified the folder structure.  The new 
structure is:

JsonDotNet
> Examples
> Source

WinRT is now fully supported.  If you don't plan to target WinRT you can exclude the entire JsonDotNet/Source/WinRT folder.  
Leaving it in will not hurt anything as the code will only compile when targetting Windows RT but you may prefer to remove it.

For more info on this asset you can visit the product page:
http://www.parentelement.com/assets/json_net_unity

There are several ways to contact me if you need support:
1.  Use the Contact link from the product page above

2.  Post a request in the official Release Thread: 
http://forum.unity3d.com/threads/200336-RELEASED-JSON-NET-For-Unity-3-5-with-AOT-Support

3.  Send me an email at:  nebraskadev@gmail.com

I will make every attempt to answer support requests as quickly as possible.  For your convenience I have included several 
sample code files in the JsonDotNet/Examples/Serialization folder.  These examples should get you started with basic serialization, 
serializing using polymorphism and using BSON for binary serialization.

Additionaly, there is an example scene in the JsonDotNet/Examples/Tests folder.  This scene runs several serialization and deserialization 
tests, displays the status of each test and logs output to the console.  There is roughly a 3 second delay between tests to give you time to 
see the results.