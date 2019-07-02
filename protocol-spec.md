ruby-debug-ide protocol
=======================

* * *

Next: [Summary](#Summary), Previous: [(dir)](#dir), Up: [(dir)](#dir)

_ruby-debug-ide_ protocol
-------------------------

This file contains specification of the protocol used by _ruby-debug-ide_.

*   [Summary](#Summary)
*   [Specification](#Specification)
*   [Changes](#Changes)

* * *

Next: [Specification](#Specification), Previous: [Top](#Top), Up: [Top](#Top)

1 Summary
---------

This document describes protocol used by _ruby-debug-ide_ for communication between debugger engine and a frontend. It is a work in progress and might, and very likely will, change in the future. If you have any comments or questions please [send me](mailto:martin.krauskopf@gmail.com) an email.

The communication has two parts/sides. First ones are _commands_ sent from a frontend to the debugger engine and the second is the opposite way, _answers_ and _events_ sent from the debugger engine to the frontend.

_commands_ are almost the same as the ones used by CLI ruby-debug. So you might want to contact [the _ruby-debug-ide_ document](http://bashdb.sourceforge.net/ruby-debug.html).

_answers_ and _events_ are sent in XML format described in the specification [below](#Specification).

**Specification is far from complete.** Will be completed as time permits. In the meantime, source code is always the best spec.

* * *

Next: [Changes](#Changes), Previous: [Summary](#Summary), Up: [Top](#Top)

2 Specification
---------------

*   [Commands](#Commands)
*   [Events](#Events)

Terms:

*   _Command_ is what frontend sends to the debugger engine
*   _Answer_ is what debugger engine sends back to the frontend
*   _Example_ shows simple example

* * *

Next: [Events](#Events), Up: [Specification](#Specification)

### 2.1 Commands

*   [Adding Breakpoint](#Adding-Breakpoint)
*   [Deleting Breakpoint](#Deleting-Breakpoint)
*   [Enabling Breakpoint](#Enabling-Breakpoint)
*   [Disabling Breakpoint](#Disabling-Breakpoint)
*   [Condition](#Condition)
*   [Catchpoint](#Catchpoint)
*   [Threads](#Threads)
*   [Frames](#Frames)
*   [Variables](#Variables)

* * *

Next: [Deleting Breakpoint](#Deleting-Breakpoint), Up: [Commands](#Commands)

#### 2.1.1 Adding Breakpoint

Command:

       break <script>:<line\_no>

Answer:

       <breakpointAdded no="<id>" location="<script>:<line\_no>"/>

Example:

       C: break test.rb:2
       A: <breakpointAdded no="1" location="test.rb:2"/>

* * *

Next: [Enabling Breakpoint](#Enabling-Breakpoint), Previous: [Adding Breakpoint](#Adding-Breakpoint), Up: [Commands](#Commands)

#### 2.1.2 Deleting Breakpoint

Command:

       delete <breakpoint\_id>

Answer:

       <breakpointDeleted no="<id>"/>

Example:

       C: delete 2
       A: <breakpointDeleted no="2"/>

* * *

Next: [Disabling Breakpoint](#Disabling-Breakpoint), Previous: [Deleting Breakpoint](#Deleting-Breakpoint), Up: [Commands](#Commands)

#### 2.1.3 Enabling Breakpoint

Supported **since** _ruby-debug-ide_ **0.2.0**

Command:

       enable <breakpoint\_id>

Answer:

       <breakpointEnabled bp\_id="<id>"/>

Example:

       C: enable 2
       A: <breakpointEnabled bp\_id="2"/>

* * *

Next: [Condition](#Condition), Previous: [Enabling Breakpoint](#Enabling-Breakpoint), Up: [Commands](#Commands)

#### 2.1.4 Disabling Breakpoint

Supported **since** _ruby-debug-ide_ **0.2.0**

Command:

       disable <breakpoint\_id>

Answer:

       <breakpointDisabled bp\_id="<id>"/>

Example:

       C: disable 2
       A: <breakpointDisabled bp\_id="2"/>

* * *

Next: [Catchpoint](#Catchpoint), Previous: [Disabling Breakpoint](#Disabling-Breakpoint), Up: [Commands](#Commands)

#### 2.1.5 Setting Condition on Breakpoint

Supported **since** _ruby-debug-ide_ **0.2.0**

Command:

       condition <script>:<line\_no>

Answer:

       <conditionSet bp\_id="<id>"/>

Example:

       C: condition 1 x>5   # Stop on breakpoint 1 only if x>5 is true.
       A: <conditionSet bp\_id="1"/>

* * *

Next: [Threads](#Threads), Previous: [Condition](#Condition), Up: [Commands](#Commands)

#### 2.1.6 Exception Breakpoint

Command:

       catch <exception\_class\_name>

Answer:

       <catchpointSet exception="<exception\_class\_name>"/>

Example:

       C: catch ZeroDivisionError
       A: <catchpointSet exception="ZeroDivisionError"/>

* * *

Next: [Frames](#Frames), Previous: [Catchpoint](#Catchpoint), Up: [Commands](#Commands)

#### 2.1.7 Threads Listing

Command:

       thread list

Answer:

       <threads>
         <thread id="<id>" status="<status>"/>
         ....
       </threads>

Example:

       C: thread list
       A: <threads>
            <thread id="1" status="run"/>
            <thread id="2" status="sleep"/>
          </threads>

* * *

Next: [Variables](#Variables), Previous: [Threads](#Threads), Up: [Commands](#Commands)

#### 2.1.8 Frames Listing

Command:

       where

Answer:

       <frames>
         <frame no="<frame\_no>" file="<script>" line="<line\_no>" current="<boolean>"/>
         <frame no="<frame\_no>" file="<script>" line="<line\_no>"/>
         ...
       </frames>

Example:

       C: where
       A: <frames>
            <frame no="1" file="/path/to/test2.rb" line="3" current="true" />
            <frame no="2" file="/path/to/test.rb" line="3" />
          </frames>

* * *

Previous: [Frames](#Frames), Up: [Commands](#Commands)

#### 2.1.9 Variables Listing

##### 2.1.9.1 Local Variables

Example:

       C: var local
       A: <variables>
            <variable name="array" kind="local" value="Array (2 element(s))" type="Array" hasChildren="true" objectId="-0x2418a904"/>
          </variables>

##### 2.1.9.2 Instance Variables

Example:

       C: var instance some\_array
       A: <variables>
            <variable name="\[0\]" kind="instance" value="1" type="Fixnum" hasChildren="false" objectId="+0x3"/>
            <variable name="\[1\]" kind="instance" value="2" type="Fixnum" hasChildren="false" objectId="+0x5"/>
          </variables>

     
       C: var instance some\_object
       A: <variables>
            <variable name="@y" kind="instance" value="5" type="Fixnum" hasChildren="false" objectId="+0xb"/>
          </variables>

* * *

Previous: [Commands](#Commands), Up: [Specification](#Specification)

### 2.2 Events

*   [Breakpoint](#Breakpoint)
*   [Suspension](#Suspension)
*   [Exception](#Exception)
*   [Message](#Message)

* * *

Next: [Suspension](#Suspension), Up: [Events](#Events)

#### 2.2.1 Breakpoint

Event example:

       <breakpoint file="test.rb" line="1" threadId="1"/>

* * *

Next: [Exception](#Exception), Previous: [Breakpoint](#Breakpoint), Up: [Events](#Events)

#### 2.2.2 Suspension

Event example:

       <suspended file="/path/to/test.rb" line="2" threadId="1" frames="1"/>

* * *

Next: [Message](#Message), Previous: [Suspension](#Suspension), Up: [Events](#Events)

#### 2.2.3 Exception

Event example:

       <exception file="/path/to/test.rb" line="2" type="ZeroDivisionError" message="divided by 0" threadId="1"/>

* * *

Previous: [Exception](#Exception), Up: [Events](#Events)

#### 2.2.4 Message

Event example:

       <message>some text</message>
       <message debug='true'>some debug text</message>

* * *

Previous: [Specification](#Specification), Up: [Top](#Top)

3 Changes
---------

Mentions also related changes in the _ruby-debug-ide_ gem implementation.

### 3.1 Changes between 0.4.9 and 0.4.10

*   Fixes possible NoSuchMethodException

### 3.2 Changes between 0.4.5 and 0.4.6

*   added Debugger::start\_server (ticket #25972)

### 3.3 Changes between 0.4.4 and 0.4.5

*   possibility to remove catchpoints
*   bugfix: syntax error with Ruby 1.9

### 3.4 Changes between 0.4.3 and 0.4.4

*   bugfix: print out backtrace when debuggee fails

### 3.5 Changes between 0.4.2 and 0.4.3

*   depends on the "~> 0.10.3.x", rather then on 0.10.3 exactly to be compatible with future ruby-debug-base 0.10.3.x releases

### 3.6 Changes between 0.4.1 and 0.4.2

*   Dependency changed to ruby-debug-base-0.10.3 which fixes various bugs and contains bunch of RFEs

### 3.7 Changes between 0.4.0 and 0.4.1

*   '–stop' switch: stop at the first line when the script is loaded. Utilized by remote debugging
*   Making '-x' switch actually work. Commenting out sending of <trace> elements to the debugger. To be decided. There are large amount of such events. For now serves rather for ruby-debug-ide developers.
*   ensure 'file' attribute contains absolute path
*   fixing CLI verbose when -d is used. Some unused code

### 3.8 Changes between 0.3.1 and 0.4.0

*   Support for debug attribute in message element. Emitted by backend when –xml-debug (new since 0.4.0) option is used.
*   More robust failures handling in DebugThread

### 3.9 Changes between 0.3.4 and 0.3.5

*   bugfix: syntax error with Ruby 1.9

### 3.10 Changes between 0.3.3 and 0.3.4

*   bugfix: print out backtrace when debuggee fails

### 3.11 Changes between 0.3.2 and 0.3.3

*   depends on the "~> 0.10.3.x", rather then on 0.10.3 exactly to be compatible with future ruby-debug-base 0.10.3.x releases

### 3.12 Changes between 0.3.1 and 0.3.2

*   Dependency changed to ruby-debug-base-0.10.3 which fixes various bugs and contains bunch of RFEs

### 3.13 Changes between 0.3.0 and 0.3.1

*   Support for _–load-mode_ option. Hotfix, likely workaround, for GlassFish debugging. Experimental, might be removed in the future. If option is used, it calls Debugger#debug\_load with increment\_start=true

### 3.14 Changes between 0.2.1 and 0.3.0

*   [Catchpoint](#Catchpoint) now answers with <conditionSet> instead of just <message> providing better control at frontend side
*   Dependency changed to ruby-debug-base-0.10.2
*   Bugfixes (see ChangeLog)

### 3.15 Changes between 0.2.0 and 0.2.1

*   Hotfixing/workarounding problem with connection on some Mac OSes, see [Debugger timing out](http://ruby.netbeans.org/servlets/BrowseList?list=users&by=thread&from=861334) thread.

### 3.16 Changes between 0.1.10 and 0.2.0

#### 3.16.1 New Features

*   [Condition](#Condition)
*   [Enabling Breakpoint](#Enabling-Breakpoint)
*   [Disabling Breakpoint](#Disabling-Breakpoint)

#### 3.16.2 Uncompatible Changes

*   _catch off_ does not work anymore, since _ruby-debug-base_s support multiple catchpoints since 0.10.1, not just one. **Note:** however _ruby-debug-base_s in version 0.10.1 suffers with [bug](http://rubyforge.org/tracker/index.php?func=detail&aid=20237&group_id=1900&atid=7436) that it is not possible to remove catchpoints. So catchpoints removing must be workarounded in higher layers. The bug is fixed in _ruby-debug-base_s 0.10.2 and above.