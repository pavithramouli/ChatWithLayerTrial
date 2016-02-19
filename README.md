# ChatWithLayerTrial
A trial swift project with LayerSDK for iOS. 

If you want to test this project, please replace the LQSLayerAppIDString constant in the LayerManager. 

1-1 chat. 1-n chat.
Login as any.
View conversation lists.
View conversation.
Add image.
Logout.

Known issues:
1) Log in as A, without logging out quit the app, relaunch and log in
as B. Conversation list retrieved is not all of B’s. Instead, log in as
A, logout and quit, relaunch and login as B, shows all conversations.
2) No methods to clear or delete chats.

Updates Planned:
1) Change from local notifications for updates to delegates. Will make life so much easier.
2) Add options to delete and clear chats. 
3) Try and check announcements. 
4) Will Layer support Push automatically? Need to check.
