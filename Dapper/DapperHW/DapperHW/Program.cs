// See https://aka.ms/new-console-template for more information
using DapperHW.Data;
using DapperHW.Models;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

Console.WriteLine("Hello, World!");

var serviceProvider = new ServiceCollection()
    .AddSingleton<IConfiguration>(new ConfigurationBuilder()
        .AddJsonFile("appsettings.json")
        .Build())
    .AddSingleton<DatabaseContext>()
    .AddSingleton<StudentRepository>()
    .AddSingleton<CourseRepository>()
    .BuildServiceProvider();

var dbContext = serviceProvider.GetService<DatabaseContext>();
await dbContext.EnsureStudentsTableExists();

var studentRepo = serviceProvider.GetService<StudentRepository>();
var courseRepo = serviceProvider.GetService<CourseRepository>();

//adding a single student

//var newStudent = new Student { Name = "John Doe", Age = 25 };
//var studentId = await studentRepo.CreateStudent(newStudent);
//Console.WriteLine($"New student created with ID: {studentId}");

//var student = await studentRepo.GetStudentById(studentId);
//Console.WriteLine($"Retrieved student: {student.Name}, Age: {student.Age}");

//student.Name = "Jane Doe";
//await studentRepo.UpdateStudent(student);
//Console.WriteLine("Student updated");

//var allStudents = await studentRepo.GetAllStudents();
//foreach (var s in allStudents)
//{
//    Console.WriteLine($"Student: {s.Name}, Age: {s.Age}");
//}

//await studentRepo.DeleteStudent(studentId);
//Console.WriteLine("Student deleted");

//Another Scenario
//•	We create 5 random literature courses.
//•	We add 3 random students to each course.
//•	We display the students for each course.

// Add 5 random courses about literature
var courses = new List<Course>
{
    new Course { Title = "Introduction to Literature", Credits = 3 },
    new Course { Title = "Shakespearean Literature", Credits = 3 },
    new Course { Title = "Modern American Literature", Credits = 3 },
    new Course { Title = "World Literature", Credits = 3 },
    new Course { Title = "Literary Theory and Criticism", Credits = 3 }
};

foreach (var course in courses)
{
    await courseRepo.CreateCourse(course);
}

// Retrieve the list of courses from the database to ensure IDs are populated
courses = (List<Course>)await courseRepo.GetAllCourses();

// Add 3 random students to each course
var random = new Random();
var studentNames = new[] { "Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Hannah", "Ivy", "Jack" };

foreach (var course in courses)
{
    for (int i = 0; i < 3; i++)
    {
        var studentx = new Student
        {
            Name = studentNames[random.Next(studentNames.Length)],
            Age = random.Next(18, 25)
        };
        var studentIdx = await studentRepo.CreateStudent(studentx);
        await courseRepo.AddStudentToCourse(course.Id, studentIdx);
    }
}

// Display students for each course
foreach (var course in courses)
{
    var students = await courseRepo.GetStudentsByCourseId(course.Id);
    Console.WriteLine($"Course: {course.Title}");
    foreach (var studentx in students)
    {
        Console.WriteLine($"  Student: {studentx.Name}, Age: {studentx.Age}");
    }
}

