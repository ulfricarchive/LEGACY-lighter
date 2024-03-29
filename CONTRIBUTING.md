Contributing to Paper
==========================
PaperMC has a very lenient policy towards PRs, but would prefer that you try and adhere to the following guidelines.

## Understanding Patches
Patches to Paper are very simple, but center around the directories 'Lighter-API' and 'Lighter-Server'

Assuming you already have forked the repository:

1. Pull the latest changes from the main repository
2. Type `./paper patch` in git bash to apply the changes from upstream
3. cd into `Lighter-Server` for server changes, and `Lighter-API` for API changes

These directories aren't git repositories in the traditional sense:

- Every single commit in Lighter-Server/API is a patch. 
- 'origin/master' points to a directory similar to Paper-Server/API but for Paper
- Typing `git status` should show that we are 10 or 11 commits ahead of master, meaning we have 10 or 11 patches that Paper and Spigot don't
  - If it says something like `212 commits ahead, 207 commits behind`, then type `git fetch` to update spigot/paper

## Adding Patches
Adding patches to Paper is very simple:

1. Modify `Lighter-Server` and/or `Lighter-API` with the appropriate changes
2. Type `git add .` to add your changes
3. Run `git commit` with the desired patch message
4. Run `./paper rebuild` in the main directory to convert your commit into a new patch
5. PR your patches back to this repository

Your commit will be converted into a patch that you can then PR into Paper

## Modifying Patches
Modifying previous patches is a bit more complex:

### Method 1
This method works by temporarily resetting HEAD to the desired commit to edit using rebase.

However, while in the middle of an edit, unless you also reset your API to a related commit, you will not be able to compile.

#### Using the Paper tool
The PaperMC build tool provides a handy command to automatically do this type of patch modification.

1. Type `./paper edit server` or `./paper edit api` depending on which project you want to edit.
  - It should show something like [this](https://gist.github.com/Zbob750/e6bb220d3b734933c320).
2. Replace `pick` with `edit` for the commit/patch you want to modify, and "save" the changes
  - Only do this for one commit at a time.
3. Make the changes you want to make to the patch.
4. Type `./paper edit continue` to finish and rebuild patches.
5. PR your modifications back to this project.

#### Manual method
In case you need something more complex or want more control, this step-by-step instruction does
exactly what the above slightly automated system does.

1. If you have changes you are working on type `git stash` to store them for later.
  - Later you can type `git stash pop` to get them back.
2. Type `git rebase -i upstream/upstream`
  - It should show something like [this](https://gist.github.com/Zbob750/e6bb220d3b734933c320).
3. Replace `pick` with `edit` for the commit/patch you want to modify, and "save" the changes.
  - Only do this for one commit at a time.
4. Make the changes you want to make to the patch.
5. Type `git add .` to add your changes.
6. Type `git commit --amend` to commit.
  - **MAKE SURE TO ADD `--amend`** or else a new patch will be created.
  - You can also modify the commit message here.
7. Type `git rebase --continue` to finish rebasing.
8. Type `./paper rebuild` in the main directory.
  - This will modify the appropriate patches based on your commits.
9. PR your modifications back to this project.

### Method 2 (sometimes easier)
If you are simply editing a more recent commit or your change is small, simply making the change at HEAD and then moving the commit after you have tested it may be easier.

This method has the benefit of being able to compile to test your change without messing with your API HEAD.

1. Make your change while at HEAD
2. Make a temporary commit. You don't need to make a message for this.
3. Type `git rebase -i upstream/upstream`, move (cut) your temporary commit and move it under the line of the patch you wish to modify.
4. Change the `pick` with `f` (fixup) or `s` (squash) if you need to edit the commit message 
5. Type `./paper rebuild` in the main directory
  - This will modify the appropriate patches based on your commits
6. PR your modifications to github


## PR Policy
We'll accept changes that make sense. You should be able to justify their existence, along with any maintenance costs that come with them. Remember, these changes will affect everyone who runs Paper, not just you and your server.
While we will fix minor formatting issues, you should stick to the guide below when making and submitting changes.

## Formatting
All modifications to non-Paper files should be marked
- Multi line changes start with `// Paper start` and end with `// Paper end`
- You can put a messages with a change if it isn't obvious, like this: `// Paper start - reason`
  - Should generally be about the reason the change was made, what it was before, or what the change is
  - Multi-line messages should start with `// Paper start` and use `/* Multi line message here */` for the message itself
- Single line changes should have `// Paper` or `// Paper - reason`
- For example:
````java
entity.getWorld().dontbeStupid(); // Paper - was beStupid() which is bad
entity.getFriends().forEach(Entity::explode());
entity.a();
entity.b();
// Paper start - use plugin-set spawn
// entity.getWorld().explode(entity.getWorld().getSpawn());
Location spawnLocation = ((CraftWorld)entity.getWorld()).getSpawnLocation();
entity.getWorld().explode(new BlockPosition(spawnLocation.getX(), spawnLocation.getY(), spawnLocation.getZ()));
// Paper end
````
- We generally follow usual java style, or what is programmed into most IDEs and formatters by default
  - This is also known as oracle style
  - It is fine to go over 80 lines as long as it doesn't hurt readability
  - There are exceptions, especially in Spigot-related files
  - When in doubt, use the same style as the surrounding code

## Obfuscation Helpers
In an effort to make future updates easier on ourselves, Paper tries to use obfuscation helpers whenever possible. The purpose of these helpers is to make the code more readable. These helpers should be be made as easy to inline as possible by the JVM whenever possible.

An obfuscation helper to get an obfuscated field may be as simple as something like this:
```java
public final int getStuckArrows() { return this.bY(); } // Paper - OBFHELPER
```
Or it may be as complex as forwarding an entire method so that it can be overriden later:
```java
public boolean be() {
    // Paper start - OBFHELPER
    return this.pushedByWater();
}

public boolean pushedByWater() {
    // Paper end
    return true;
}
```
While they may not always be done in exactly the same way each time, the general goal is always to improve readability and maintainability, so use your best judgement.

## Configuration files
To use a configurable value in your patch, add a new entry in either ```PaperConfig``` or ```PaperWorldConfig```. Use the former if a value must remain the same throughout all worlds, or the latter if it can change between worlds. The latter is preferred whenever possible.

###```PaperConfig``` example:
```java
public static boolean saveEmptyScoreboardTeams = false;
private static void saveEmptyScoreboardTeams() {
    saveEmptyScoreboardTeams = getBoolean("settings.save-empty-scoreboard-teams", false);
}
```
Notice that the field is always public, but the setter is always private. This is important to the way the configuration generation system works. To access this value, reference it as you would any other static value:
```if (!PaperConfig.saveEmptyScoreboardTeams) {```

###```PaperWorldConfig``` example:
```java
public boolean useInhabitedTime = true;
private void useInhabitedTime() {
    useInhabitedTime = getBoolean("use-chunk-inhabited-timer", true);
}
```
Again, notice that the field is always public, but the setter is always private. To access this value, you'll need an instance of the ```net.minecraft.World``` object:

```return this.world.paperConfig.useInhabitedTime ? this.w : 0;```
