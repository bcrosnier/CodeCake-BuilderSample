using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CodeCake;

namespace CodeCakeBuilder
{
    class Program
    {
        /// <summary>
        /// The main entry point of the CodeCake builder for this project.
        /// </summary>
        /// <param name="args"></param>
        static int Main( string[] args )
        {
            // This will be the root directory where CodeCake will run from.
            // This is usually the solution directory.
            // Here we use the current directory, so watch where you run!
            string rootDirectory = Environment.CurrentDirectory;

            // The builder application that we will run.
            // The assembly we give it (ourselves) should have a type names Build deriving from CodeCakeHost.
            // See actual BuildProcess.cs.
            var builderApp = new CodeCakeApplication( rootDirectory, typeof(Program).Assembly );

            // You can check for custom arguments.
            bool interactive = !args.Contains( '-' + InteractiveAliases.NoInteractionArgument, StringComparer.OrdinalIgnoreCase );

            // The actual run. Args will be passed along to Cake.
            int result = builderApp.Run( args );

            Console.WriteLine();
            if( interactive )
            {
                Console.WriteLine( "Press any key to exit. (Use the -{0} flag to skip)", InteractiveAliases.NoInteractionArgument );
                Console.ReadKey();
            }
            return result;

        }
    }
}
