# Cygnet for Fleet

Cygnet is a native iOS app that uses the Fleet REST API to display information about your hosts. A native experience combined with the speed of the Fleet API means you can get to the information you’re looking for fast.

I’ve created Cygnet as a project to help me continue learning Swift and SwiftUI. As such, I welcome contributors to offer improvements to help me with my learning.

Crashes and bugs are expected. If you encounter any while using the app, please create an issue!

## Availability

Cygnet is currently available on [TestFlight](https://testflight.apple.com). You can download TestFlight on your device from the App Store.

Once you have TestFlight installed, you can join the Cygnet for Fleet public beta by clicking [here](https://testflight.apple.com/join/VH22aGlx).

## Authentication

### Signing In

To use the app, you’ll need to provide the URL to your Fleet server and valid credentials. The app has been designed with global admin users in mind, but at the moment other global roles and team-based users should also work.

If you have SSO authentication enabled on your account, you’ll need to sign in with an API token. Just flip the toggle on the login screen to enter your API token.

Unfortunately, at the moment you can’t sign in to the Fleet UI on mobile to get your API token. The [Universal Clipboard](https://support.apple.com/en-us/102430) feature works great if you have a Mac nearby to copy your API token and paste it into Cygnet on your mobile device.

### Token Renewal

When your API Token expires, Cygnet will attempt to handle it depending on your initial authentication method.

If you signed in with a username and password, Cygnet will automatically retrieve a new API token. This should work as long as your email or password has not changed since your last login. If your email or password has changed, you’ll need to sign out of the app and re-enter your credentials.

If you signed in with an API token, Cygnet will notify you and prompt you to enter a new API token.

## Features

### Dashboard
Get a quick overview of your Fleet instance with a summary of enrolled hosts, users, software, and policies, along with a visual breakdown of hosts by platform.

### Hosts
Hosts allows you to view all your enrolled hosts. If you have an environment with multiple teams, you can filter hosts by those teams.

When you select an individual host, you’ll be able to see more details about it, including:
- **Device Information**: Hardware details and OS version.
- **Storage**: Current disk usage.
- **Activity**: Enrolled date, last seen time, and uptime.
- **Network**: Public/private IP addresses and MAC address.
- **Battery**: Health and cycle count.
- **Management**: Assigned policies, installed software, and MDM configuration profiles.

You can also send MDM commands (such as Lock, Restart, or Shutdown) and view the command history for a host.

### Users
Users allows you to view all the users in your Fleet instance.
If you filter by Team, you’ll see all the users that have access to that team in addition to global users. Tap into a user to see more information about them, including which teams they have access to and what permissions they have.

### Software
Software shows all known software titles running on your enrolled hosts. You can tap into any software title to see which hosts are running that title and version. If that version has known vulnerabilities, you’ll be able to see them and their severity.

### Policies
If you are using policies in your Fleet environment, you’ll be able to see them in this view. Policies will show you the number of hosts passing or failing that policy. You can tap into a policy to see the query it’s running as well as which individual hosts are passing/failing.

Right now, policies are segmented by team. Cygnet gives you the option to see ALL policies (policies assigned globally AND to team) or policies assigned to a team. Policies inherited as a global policy do appear when you have a team selected.
