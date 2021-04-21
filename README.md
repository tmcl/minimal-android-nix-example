A minimal Android/Nix example
=============================

This draws entirely on the work of github.com/tadfisher, who basically did
all the work and almost documented it. Consider this a tutorial in one way
to use their stuff. Most significantly, I using android-nixpkgs and guided
by [this gist](https://gist.github.com/tadfisher/17000caf8653019a9a98fd9b9b921d93).

The first thing to do, then, is to grab android-studio:

```bash
NIXPKGS_ALLOW_UNFREE=1 nix-shell -p android-studio --pure
android-studio
```

In fact, we won't be using this to build our product. We're only going to
use it to generate our product. It will download a bunch of massive build 
tools, SDKs, images etc. We're not going to use them. In practice I think
you'll probably use them, because actually using Android Studio to do the
development work is probably somewhere between reasonable and the correct
choice. But perhaps you can find a way to avoid doing this if you know it
won't be the tool you use to do your work.

When it starts, choose "Create New Project", "Empty Activity" and set the
language to Kotlin and Minimum SDK, well, I've only used 28 because I was
motivated to write an Android app because it was about that time the apps
I like started breaking. Here I've been daring and chosen 24. When you've
made your choices, press "Finish".

Android Studio will generate a bunch of files. Then I added everything to
git and closed it. From now on, we will be working without it.

In an adjacent folder, I created several files based on, but not the same
as, the files from tadfisher's gists. I will discuss each file along with
what changes I made. You can follow on by looking at the diffs. 

The first is `nix/default.nix`. First, I need to pin nixpkgs and also add
tadfisher/android-nixpkgs to give us access to the SDK. Instead of taking
a custom build of gradle, we just use the nixpkgs gradle\_6 package since
Android Studio has generated code for gradle 6 which is incompatible with
gradle 7. (It uses 6.5; but nixpkg's 6.8 is close enough.)

If you run `nix-build default.nix` now, it will error because it wants to
import deps.json. This file is produced by `updateLocks`, which builds an
executable. If you run it `./result/bin/update-locks`, it fails. Firstly,
the pwd when it runs needs to be our gradle/Android project: 

```bash
../nix% nix-build default.nix --attr update-locks
../nix% cd ../android
../android% ../nix/result/bin/update-locks
```

Secondly, it runs `gradle lock`, which is not a provided/builtin task. No
problem, we can simply change it to use the builtin `gradle dependencies` 
instead. Then rebuild it, go back to `../android` and run it as above and 
you get a `deps.json`. Move it back to `../nix` and review the commit.

Now we are good to try and run our main `nix-build default.nix` again:

```bash
../nix% nix-build default.nix 
```

This deps.json file contains a reference to all our android dependencies. 
It has their names and sha224 sums, but it doesn't tell us where they are
downloaded from. Therefore, we get another failure. In default.nix, there
is a call to maven-repo.nix, which supplies references to the maven repos 
that it looks at to find the dependencies. You can compare these repos to
the repositories mentioned in ../android/build.gradle: build.gradle looks
at (twice):

```gradle
    repositories {
        google()
        jcenter()
    }
```

JCenter is going to be closed and when you build this, it will advise you
to replace it with mavenCentral(). Maven Central is repo1.maven so we can
use that in our build.gradle file (twice) and add the google repo: 


```gradle
    repositories {
        google()
        mavenCentral()
    }
```

```nix
    repos = [
      "https://dl.google.com/dl/android/maven2"
      "https://maven.pkg.jetbrains.space/kotlin/p/kotlin/dev"
      "https://plugins.gradle.org/m2"
      "https://repo1.maven.org/maven2"
    ];
```

The order is significant: Java builds are not very reproducible thus when 
the same package is included in two repos they are sufficiently likely to 
have two different SHA224. (Also, JetBrains artefacts might be downloaded
and shared as part of the IDE. These can be found by general sleuthing. I
have included an additional repo that solves a version mismatch from when
I wrote this up, that I didn't experience when actually trying to make it
work in the first place.)

Now we can commit and rebuild; this time it gets to builtWithGradle. This
time it fails because of a difference in code layout. Go to build.nix and
point it to the sources.

```nix
stdenv.mkDerivation {
  pname = "built-with-gradle";
  version = "0.0";

  src = ../android;
  ...
}
```

Now it fails because it can't find its dependencies and wants to download
its dependencies, but the nix sandbox won't let it. We have built a local
repo, but not pointed it to it. If you want to build this by hand, we can
just add mavenLocal() before google():

```gradle
    repositories {
        mavenLocal()
        google()
        mavenCentral()
    }
```

and change the build.nix file to use -Dmaven.repo.local=${mavenRepo}, but
for whatever reason maven seems to ignore the local repo settings when it
is used by system users. Or something. Tadfisher provided some tools that
should read a property -DnixMavenRepo. I have very limited skills, and so
I struggled to get it to work. Instead, I have used -PnixMavenRepo in the
build.nix file and substituted  the simple repo code above with a test to
see if it has been defined and, if so, to use it (twice):

```kotlin
    val nixMavenRepo = project.findProperty("nixMavenRepo")
    if(nixMavenRepo != null) {
      repositories {
          maven(nixMavenRepo)
      }
    } else {
      repositories {
          google()
          mavenCentral()
      }
    }
```

(I also converted the file to kts, but I'm quite sure that's unnecessary.
I might change it back because I don't know how to register the task...)
