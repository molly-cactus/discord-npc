# discord-npc

A tiny tool for roleplaying in a Discord channel.

**TODO:** Available characters should come from the server, not the client?
Or maybe both, with the option to send images over the connection. Maybe the server could cache them?

Also, if the client does send stuff, it should just blindly merge the character's hash over the secrets hash; that way we don't care about the specifics too much, and improvements become easier.

Characters should also be defined by something actually unique on the server... maybe by the hash code of their name, client id and channel id?

Too much knowledge about the bots has to be transmitted every single time; why can't the server remember their image, their name, etc?

**Step 1:** The server knows what characters exist; the client can use those characters. What about the token, though? It would make sense to leave it with the client as a means of authentication; but this would also require duplication, in the form of two (or more...) character files, one on each end. Maybe this is too much.

**Step 2:** The client can suggest new characters, which the server then remembers.
