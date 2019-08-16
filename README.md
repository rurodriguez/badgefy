Badgefy
=======
![](https://lh3.googleusercontent.com/-7F-Kulfo2PE/V17S96Kh1wI/AAAAAAAAEns/nDApM3A-DnEijFGpMfLgmgigMpu-ZXxwACCo/s96/ic_launcher_dev.png)![](https://lh3.googleusercontent.com/-ZV-BIuNpFGA/V17S-EG53mI/AAAAAAAAEn0/KIzN2H_G33wFI2WnfZE2ME3tjCav-dpGQCCo/s96/ic_launcher_prod.png)

Example project with a couple of scripts (gradle / bash), which allow you to insert a ribbon in to the Android launcher icon with flavor and version of the app (for example).

This script should works both Linux and Mac OS (sorry Windows Users!)

**Prerequisites**
 * imagemagick
 * ghostscript

An easy way to install them is through homebrew ( http://brew.sh ):
```bash
$ brew update
$ brew install imagemagick ghostscript
```

**Key files**

*add_icon_overlay.sh*

This file contains the bash script to insert the ribbons in to the Android launcher icon.

*Montserrat-Bold.ttf*

The font type you wish to use to render the text. You can change it if you wish, but be careful because not all the font types are rendered correctly.

*app build.gradle*

This files contains the tasks needed to call *add_icon_overlay.sh* in the right place. These are the needed tasks/defs to make it works

```gradle
/*
*
* creating the icon overlay task for each build variant
*
* */
def versionBuild = 1
def createdTasks = []
android.applicationVariants.all { variant ->
    def buildType = variant.buildType.name
    def flavor = ""
    variant.productFlavors.each { variantFlavor ->
        flavor = variantFlavor.name
        def taskName = "addIconOverlay${flavor}${buildType}Task"

        // create the task only if it has not been created before
        if (!createdTasks.contains(taskName)) {
            createdTasks.add taskName
            tasks.create([name: taskName, type: Exec], {
                def cornerBackgroundColor
                def textColor
                def shadowColor

                if (flavor.equals("dev")) {
                    cornerBackgroundColor = "#f8e543" //corner background color of the ribbon for dev flavor
                    textColor = "#000000" //text color of the ribbon for dev flavor
                    shadowColor = "#eeeeee" //shadow color of the ribbon for dev flavor

                }
                else {
                    cornerBackgroundColor = "#a5238f" //corner background color of the ribbon for NON dev flavor
                    textColor = "#ffffff" //text  color of the ribbon for NON dev flavor
                    shadowColor = "#eeeeee" //shadow color of the ribbon for NON dev flavor
                }

                commandLine '/bin/bash', "./add_icon_overlay.sh", "${versionBuild}", "${flavor}", "${buildType}", "${cornerBackgroundColor}", "${textColor}", "${shadowColor}"
            })
        }
    }
}

/*
* gnerateDevDebugResources depends on addIconOverlayDevDebugTask
*
* this is the only way I found where the launcher icons are modfied
* BEFORE processed (generateXXResources)
* */

tasks.whenTaskAdded { task ->
    def taskName = task.name
    def buildType = ""
    def flavor = ""
    def buildVariant = ""
    if (taskName.startsWith("generate") && taskName.endsWith("Resources") && !taskName.contains("Release")) {
        buildVariant = taskName.replace("generate", "").toLowerCase()
        buildVariant = buildVariant.replace("Resources", "")
    }

    android.applicationVariants.all { variant ->
        if (buildVariant.contains(variant.buildType.name)) {
            buildType = variant.buildType.name
            variant.productFlavors.each { variantFlavor ->
                if (buildVariant.contains(variantFlavor.name)) {
                    flavor = variantFlavor.name
                    def t = tasks["addIconOverlay${flavor}${buildType}Task"]
                    if (taskName.startsWith("generate")) {
                        task.dependsOn t
                    }
                }
            }
        }
    }
}
```

License
-------

    Copyright 2016 Rubén Rodríguez

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

