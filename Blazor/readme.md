# Blazor

Let's learn about Blazor.

List of Topics.

1. Overview of Blazor
1. Blazor components and routing
1. Building interactive web UIs
1. Integrating Blazor with .NET Core

### Overview of Blazor

Blazor is a framework for building interactive web applications using C# and .NET. It allows developers to create rich, modern web applications without writing JavaScript. Blazor can run client-side in the browser using WebAssembly or server-side in ASP.NET Core.

#### Key Features of Blazor

1. **Full-Stack Development with C#**: Write both client-side and server-side code in C#.
2. **Reusability**: Reuse existing .NET libraries and code across different parts of the application.
3. **Component-Based Architecture**: Build applications using reusable components.
4. **WebAssembly**: Run .NET code directly in the browser using WebAssembly.
5. **Interoperability**: Integrate with JavaScript libraries and frameworks when needed.
6. **Live Reload**: Supports hot reload, allowing developers to see changes immediately without rebuilding the entire application.

#### Blazor Hosting Models

Blazor offers two hosting models:

1. **Blazor WebAssembly (Client-Side)**: Runs the application directly in the browser using WebAssembly. This model allows for a rich, interactive experience with reduced server load. The application is downloaded to the client and executed in the browser.

2. **Blazor Server**: Runs the application on the server and uses SignalR to communicate with the browser. This model provides a lightweight client footprint and faster initial load times. The server handles the execution of the application logic and sends UI updates to the client.

#### Creating a Blazor WebAssembly Application

Let's create a simple Blazor WebAssembly application to demonstrate the basics of Blazor.

##### Step 1: Create a New Blazor WebAssembly Project

You can create a new Blazor WebAssembly project using the .NET Core CLI or Visual Studio.

###### Using the .NET Core CLI

1. **Open a command prompt or terminal**.
2. **Run the following command to create a new Blazor WebAssembly project**:
   ```bash
   dotnet new blazorwasm -o MyBlazorApp
   ```
   This command creates a new Blazor WebAssembly project in a directory named `MyBlazorApp`.

3. **Navigate to the project directory**:
   ```bash
   cd MyBlazorApp
   ```

4. **Run the application**:
   ```bash
   dotnet run
   ```
   Open a browser and navigate to `http://localhost:5000` to see the default Blazor WebAssembly application.

##### Step 2: Understanding the Project Structure

A typical Blazor WebAssembly project has the following structure:

```plaintext
MyBlazorApp/
├── wwwroot/
│   └── css/
│   └── sample-data/
│   └── index.html
├── Pages/
│   └── Counter.razor
│   └── FetchData.razor
│   └── Index.razor
├── Shared/
│   └── MainLayout.razor
│   └── NavMenu.razor
├── _Imports.razor
├── App.razor
├── Program.cs
└── MyBlazorApp.csproj
```

- **wwwroot/**: Contains static assets such as CSS, JavaScript, and images.
- **Pages/**: Contains Razor components that represent individual pages in the application.
- **Shared/**: Contains shared components and layouts used across the application.
- **_Imports.razor**: Provides common using directives for Razor components.
- **App.razor**: Defines the root component of the application.
- **Program.cs**: Contains the `Main` method, which is the entry point of the application.
- **MyBlazorApp.csproj**: Project file defining dependencies and build configuration.

##### Step 3: Creating a New Component

Create a new Razor component named `HelloWorld.razor` in the `Pages` folder.

```csharp name=Pages/HelloWorld.razor
@page "/helloworld"

<h3>Hello, World!</h3>
<p>Welcome to Blazor!</p>
```

- **@page "/helloworld"**: Specifies the route for the component.

##### Step 4: Adding Navigation

Add a link to the new `HelloWorld` component in the `NavMenu.razor` file.

```html name=Shared/NavMenu.razor
<NavLink class="nav-link" href="helloworld">
    <span class="oi oi-list-rich" aria-hidden="true"></span> Hello World
</NavLink>
```

##### Step 5: Running the Application

Run the application using the following command:
```bash
dotnet run
```
Open a browser and navigate to `http://localhost:5000/helloworld` to see the new `HelloWorld` component.

### Conclusion

Blazor is a powerful framework for building interactive web applications using C# and .NET. By following the steps outlined above, you can create a simple Blazor WebAssembly application that demonstrates the basics of Blazor, including creating components and adding navigation.

### Blazor Components and Routing

Blazor components are the building blocks of a Blazor application. They encapsulate both markup and logic in a single unit. Routing in Blazor is used to map URLs to component pages, enabling navigation within the application.

#### Creating Blazor Components

A Blazor component is defined using a `.razor` file. Each component can include HTML markup, C# code, and Razor syntax.

##### Example: Creating a Counter Component

```csharp name=Pages/Counter.razor
@page "/counter"

<h3>Counter</h3>

<p>Current count: @currentCount</p>

<button class="btn btn-primary" @onclick="IncrementCount">Click me</button>

@code {
    private int currentCount = 0;

    private void IncrementCount()
    {
        currentCount++;
    }
}
```

In this example:
- **@page "/counter"**: Defines the route for the Counter component.
- **HTML markup and Razor syntax**: Define the structure and behavior of the UI.
- **@code block**: Contains the C# code for the component.

#### Component Parameters

Components can accept parameters, allowing you to pass data from parent components to child components.

##### Example: Creating a Greeting Component with Parameters

```csharp name=Pages/Greeting.razor
@page "/greeting/{Name}"

<h3>Greeting</h3>

<p>Hello, @Name!</p>

@code {
    [Parameter]
    public string Name { get; set; }
}
```

In this example:
- **@page "/greeting/{Name}"**: Defines the route with a parameter.
- **[Parameter]**: Attribute indicates that the `Name` property is a parameter that can be passed to the component.

#### Routing

Blazor uses the `Router` component to map URLs to components. The `Router` component is usually defined in the `App.razor` file.

##### Example: App.razor File

```csharp name=App.razor
<Router AppAssembly="@typeof(App).Assembly">
    <Found Context="routeData">
        <RouteView RouteData="@routeData" DefaultLayout="@typeof(MainLayout)" />
        <FocusOnNavigate RouteData="@routeData" Selector="h1" />
    </Found>
    <NotFound>
        <LayoutView Layout="@typeof(MainLayout)">
            <p>Sorry, there's nothing at this address.</p>
        </LayoutView>
    </NotFound>
</Router>
```

In this example:
- **Router**: The `Router` component handles URL matching and navigation.
- **AppAssembly**: Specifies the assembly that contains the components.
- **Found**: Defines what to render when a route is found.
- **NotFound**: Defines what to render when no route is found.

#### Adding Navigation

Navigation links can be added using the `NavLink` component. The `NavLink` component automatically applies an active CSS class to the link that matches the current URL.

##### Example: NavMenu.razor File

```csharp name=Shared/NavMenu.razor
<NavMenu>
    <NavLink class="nav-link" href="">Home</NavLink>
    <NavLink class="nav-link" href="counter">Counter</NavLink>
    <NavLink class="nav-link" href="greeting/JohnDoe">Greeting</NavLink>
</NavMenu>
```

In this example:
- **NavLink**: Creates navigation links to the different components.
- **href**: Specifies the URL to navigate to.

### Conclusion

Blazor components are the fundamental building blocks of Blazor applications, encapsulating both markup and logic. Routing in Blazor allows you to map URLs to components, enabling navigation within the application. By creating components, defining routes, and adding navigation links, you can build rich, interactive web applications using Blazor.

