#!/bin/bash

# Set the project name
PROJECT_NAME="BlazorProjectName"

# Create the root directory
mkdir $PROJECT_NAME

# Navigate into the root directory
cd $PROJECT_NAME

# Create the Solution
dotnet new sln -n $PROJECT_NAME

# Create the Blazor WebAssembly (Client) Project
dotnet new blazorwasm -n $PROJECT_NAME.Client

# Create the ASP.NET Core Web API (Server) Project
dotnet new webapi -n $PROJECT_NAME.Server

# Create the Shared Class Library Project
dotnet new classlib -n $PROJECT_NAME.Shared

# Rename the Server.csproj to $PROJECT_NAME.Server.csproj
mv  $PROJECT_NAME.Server Server
mv  $PROJECT_NAME.Shared Shared
mv  $PROJECT_NAME.Client Client


# Add Projects to the Solution
dotnet sln add Client/$PROJECT_NAME.Client.csproj
dotnet sln add Server/$PROJECT_NAME.Server.csproj
dotnet sln add Shared/$PROJECT_NAME.Shared.csproj

# Set Up Project References
dotnet add Server/$PROJECT_NAME.Server.csproj reference Shared/$PROJECT_NAME.Shared.csproj
dotnet add Server/$PROJECT_NAME.Server.csproj reference Client/$PROJECT_NAME.Client.csproj
dotnet add Client/$PROJECT_NAME.Client.csproj reference Shared/$PROJECT_NAME.Shared.csproj

# Add Microsoft.AspNetCore.Components.WebAssembly.Server package to the Server project
dotnet add Server/$PROJECT_NAME.Server.csproj package Microsoft.AspNetCore.Components.WebAssembly.Server
dotnet add Server/$PROJECT_NAME.Server.csproj package Npgsql
dotnet add Server/$PROJECT_NAME.Server.csproj package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add Server/$PROJECT_NAME.Server.csproj package Npgsql.NetTopologySuite

# Replace the Program.cs file in the Server project with the provided content
cat > Server/Program.cs <<EOL
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddControllersWithViews();
builder.Services.AddRazorPages();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseBlazorFrameworkFiles();
app.UseStaticFiles();

app.UseRouting();

app.UseEndpoints(endpoints =>
{
    endpoints.MapRazorPages();
    endpoints.MapControllers();
    endpoints.MapFallbackToFile("index.html");
});

app.Run();
EOL

# Build the Solution
dotnet build

echo "Blazor WebAssembly project with client/server/shared structure created successfully."

cd Server

dotnet run