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
