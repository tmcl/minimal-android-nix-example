A minimal Android/Nix example
=============================

This draws entirely on the work of github.com/tadfisher, who basically did
all the work and almost documented it. Consider this a tutorial in one way
to use their stuff. Most significantly, I using android-nixpkgs and guided
by [this gist](https://gist.github.com/tadfisher/17000caf8653019a9a98fd9b9b921d93).

This should be usable by:

1. Checking it out.
2. Producing the update-locks script
3. Running the update-locks script in the android package
4. Building it.


```bash
1% git checkout https://github.com/tmcl/minimal-android-example
2% nix-build -A updateLocks
3% cd ../android
3% ../nix/result/bin/update-locks
3% mv deps.json ../nix
3% cd ../nix
4% nix-build

```

But it isn't. Different compilations of the same maven packages that use
the same name and version but have different SHA224 sums are uploaded to
different repos. In order to get the same dependencies from update-locks 
and the nix script, you might need to reorder the repos in default.nix a
few times (and use --keep-going). Eventually it will build.

I show my working in the history of this repo. This may be useful if you
want help adding this to your own project.
