# Get-RdsSetting

I had an request from a client to report on the number of users that had the
"Deny this user permissions to log on to Remote Desktop Session Host server" setting
enabled as they suspected it was causing an issue launching some XenApp applications.

Saw this as an opportunity to explore some methods I'd never used before to query AD User
settings.

The AD OU Structure I was dealing with had three regions hence the param switch values
but these can of course be changed to suit your requirement as you see fit.
