# One Minute Timer

I have been practicing Azure Functions for my 2nd attempt at AZ 204.

I figured to do a deep dive into the following concepts (because, I realized after I failed my AZ 204 exam, I did not do enough hands on exercises.

1. Azure Functions App
2. Infrastructure as Code - Bicep Files
3. Application Insights 
4. Storage Account
5. Azure Cosmo DB (although, this did not work, because, to make make management identity work with cosmos I needed to buy a license. managed identity works just fine with application insights and Azure Functions Storage Account) But I left the code here, in case someone or myself tries to run it with a proper license in the future.
1. AZD command line tool
1. AZ command line tool
1. Powershell 7 and Powershell 5
2. Azure Cloud Shell
3. Visual Studio and Visual Studio Code (for debugging an development)
1. Virtual Network and Private EndPoints

So, adding a project that does all the above.

Note: As usual, the original source code is available here : https://github.com/Azure-Samples/functions-quickstart-dotnet-azd-cosmosdb . This is simply my remix version with my own experimentations. 

# After you run this 

You should see stuff like this (and all the counterparts on the azure portal)

(✓) Done: Resource group: rg-funcpractice21novcxyz (900ms)
(✓) Done: App Service plan: plan-bmgayhdpw7smi (2.78s)
(✓) Done: Virtual Network: vnet-bmgayhdpw7smi (2.977s)
(✓) Done: Log Analytics workspace: log-bmgayhdpw7smi (21.799s)
(✓) Done: Storage account: stbmgayhdpw7smi (26.387s)
(✓) Done: Application Insights: appi-bmgayhdpw7smi (4.58s)
(✓) Done: Azure Cosmos DB: cosmos-bmgayhdpw7smi (2m20.589s)
(✓) Done: Private Endpoint: blob-private-endpoint (30.341s)
(✓) Done: Function App: func-api-bmgayhdpw7smi (50.392s)
(✓) Done: Private Endpoint: db-private-endpoint (9m35.233s)

And, if you check out application insights logs, and run the 'traces' query, you should see the function app coming alive every minute and do something. 

# book a session with me

1. [calendly](https://calendly.com/jaycodingtutor/30min)

# hire and get to know me

find ways to hire me, follow me and stay in touch with me.

1. [github](https://github.com/Jay-study-nildana)
1. [personal site](https://thechalakas.com)
1. [upwork](https://www.upwork.com/fl/vijayasimhabr)
1. [fiverr](https://www.fiverr.com/jay_codeguy)
1. [codementor](https://www.codementor.io/@vijayasimhabr)
1. [stackoverflow](https://stackoverflow.com/users/5338888/jay)
1. [Jay's Coding Channel on YouTube](https://www.youtube.com/channel/UCJJVulg4J7POMdX0veuacXw/)
1. [medium blog](https://medium.com/@vijayasimhabr)