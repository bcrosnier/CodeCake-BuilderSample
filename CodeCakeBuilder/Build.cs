using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CodeCake;
using Cake.Core;
using Cake.Common.Diagnostics;
using Cake.Common.Solution;
using Cake.Common.Solution.Project;
using Cake.Common.Tools.MSBuild;
using Cake.Common.Tools.NuGet;
using Cake.Common.IO;
using Cake.Core.IO;
using Cake.Common;

namespace CodeCakeBuilder
{
    /// <summary>
    /// The actual build process. This is the Cake part of CodeCake.
    /// </summary>
    /// <remarks>
    /// The AddPathAttribute adds to the PATH environment variable, which can be used to reference tools 
    /// (by Cake, or by you). It's relative to the path given to CodeCakeApplication in Program.cs.
    /// Cake Tool information: http://cakebuild.net/docs/tools/tool-resolution.
    /// </remarks>
    [AddPath( "CodeCakeBuilder/Tools" )]
    public class Build : CodeCakeHost
    {
        /// <summary>
        /// All the setup is done in the constructor.
        /// </summary>
        public Build()
        {
            var target = Cake.Argument("target", "Default");

            Task( "Build" ).Does( () =>
            {
                // The Cake property (Cake.Core.ICakeContext) is used for the Cake DSL. http://cakebuild.net/dsl
                // Since everything in the DSL is an extension method to ICakeContext,
                // you'll need the relevant namespaces in the file's usings.
                // The full list is at http://cakebuild.net/api/cake.common

                Cake.Information( "Ahoy!" ); // Information() is in Cake.Common.Diagnostics. http://cakebuild.net/api/cake.common.diagnostics

                IEnumerable<FilePath> slnFilePaths = Cake.GetFiles( "*.sln" );
                foreach( FilePath slnFilePath in slnFilePaths )
                {
                    Cake.MSBuild( slnFilePath );
                }
            } );

            // When run with nothing, CodeCake will run the target "Default".
            // To run something else, call the executable with a -target argument:
            //   CodeCakeBuilder.exe -target=Build
            Task( "Default" )
                .IsDependentOn( "Build" );
        }

    }
}
