# ValleybrookMessenger
This is an app that I created for potential usage by my church.

There are two types of users for this app: normal church members and administrators.

Church members are able to login to their account and choose which groups they would like to be a part of and receive communications (emails and texts) from.

Administrators can be members of groups as well but they can also add/delete groups, see who is in each group, and send emails and texts to all members of specified groups.

To be an administrator, the admin property of your account must be set to true, which can only be done manually in Firebase. In order to allow you to test the whole app, I've set up an administrator account that you can login as:

email: test@test.com
password: password

If you login with these credentials, you'll be able to access the entire app. You can also test out creating a new profile by using any random email/password combination.

I'll give a brief description of each view below:

LOGIN VIEW

This is where you can login to your account or create a new account by selecting "Don't have an account? Create Profile." If you already have an account, you can login and you'll be taken directly to the Subscriptions view. If you don't already have an account, you can select "Don't have an account? Create Profile." and you'll be taken to the Create Profile view.

CREATE PROFILE VIEW

Here you may enter a Name, Email, Phone, and Password. If everything is entered in the proper format, you can hit submit, your account will be created, and you'll be directed to the Subscriptions View.

SUBSCRIPTIONS VIEW

This is where you can choose which groups to be a part of by turning the UISwitch of each group either on or off. In the upper left is an option to logoff, and in the upper right is an option to edit your profile, which will take you to a modified version of the Create Profile view where you can submit changes. If you're not an administrator, the Subscriptions view is the only view you can see. If you are an administrator, you will see a button at the bottom of the view that says "Manage Groups as Administrator". Select this button to go to the Groups View.

GROUPS VIEW

Here is where as an administrator you can add/delete groups and select groups to see their members in the Members view. There is also a group which cannot be deleted called "All Users" which shows everyone who has created an account. At the bottom of this view is a button that says "Create Message" which will take you to the Configure Message View.

MEMBERS VIEW

This shows all the members of a selected group. Selecting a member will call the number associated with them.

CONFIGURE MESSAGE VIEW

Here you can select which groups to send an email or text to, write the subject and message, and select either "Send Email" or "Send Text"
