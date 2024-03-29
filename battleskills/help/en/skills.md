---
toc: Using Battle
summary: Choosing your character's skills.
order: 2
aliases:
- reset
- language
- languages
- raise
- lower
- ability
- attribute
- attributes
- specialty
- specialties
- advantages
- abilities
---
# Battle Skills

This game uses the Battle skills system, Third Edition.  The complete rulebook can be found online: [FS3 Player's Guide](http://www.aresmush.com/fs3/fs3-3).

## Resetting Skills

To get started, or at any point you wish to reset yourself, use the reset command.

`reset` - Resets your abilities, setting default values based on your groups.
         **This will erase any abilities you have, so do this first!**

## Viewing Your Sheet

At any time you can check your current status and progress using the `sheet` and `app` commands.

## Raising Abilities

Use the Abilities command to see the ratings, available abilities and descriptions.

`abilities` - Lists abilities.

There are two ways to adjust your abilities.  All abilities use the same commands:   

`raise <name>` and `lower <name>` - Raise or lower by 1 level.
`ability <name>=<level>` - Sets the rating

## Adding Specialties

Some abilities require specialization.  You can add or remove a specialty:

`specialty/add <ability>=<specialty>` or `specialty/remove <ability>=<specialty>`

## Finding Other People With Skills

If you're looking for a character with a specific skill, you can use the skill scan command (if the game has enabled visible sheets).  It will list anyone with that skill above Everyman (or above Average for attributes).  People in your room are highlighted.  You can also see a summary of people within the different skill categories.

`skill/scan <specific skill name>` - Find people with that skill.
`skill/scan <action, background, language>` - Summarize peoples' skill levels. Only skills held by 2 or more people are shown to cut down on spam.
