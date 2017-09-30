_ruby-debug-ide_ protocol
=========================

This file contains specification of the protocol used by
_ruby-debug-ide_.

1 Summary
=========

This document describes protocol used by _ruby-debug-ide_ for
communication between debugger engine and a frontend. It is a work in
progress and might, and very likely will, change in the future. If you
have any comments or questions please send me
<martin.krauskopf@gmail.com> an email.

   The communication has two parts/sides. First ones are _commands_
sent from a frontend to the debugger engine and the second is the
opposite way, _answers_ and _events_ sent from the debugger engine to
the frontend.

   _commands_ are almost the same as the ones used by CLI ruby-debug.
So you might want to contact the _ruby-debug-ide_ document
(http://bashdb.sourceforge.net/ruby-debug.html).

   _answers_ and _events_ are sent in XML format described in the
specification *Note below: Specification.

   *Specification is far from complete.* Will be completed as time
permits.  In the meantime, source code is always the best spec.

2 Specification
===============

Terms:
   * _Command_ is what frontend sends to the debugger engine

   * _Answer_ is what debugger engine sends back to the frontend

   * _Example_ shows simple example

2.1 Commands
------------

### 2.1.1 Adding Breakpoint

Command:

       break <script>:<line_no>

   Answer:

       <breakpointAdded no="<id>" location="<script>:<line_no>"/>

   Example:

       C: break test.rb:2
       A: <breakpointAdded no="1" location="test.rb:2"/>

### 2.1.2 Deleting Breakpoint

Command:

       delete <breakpoint_id>

   Answer:

       <breakpointDeleted no="<id>"/>

   Example:

       C: delete 2
       A: <breakpointDeleted no="2"/>

### 2.1.3 Enabling Breakpoint

Supported _*since*_ _ruby-debug-ide_ _*0.2.0*_

   Command:

       enable <breakpoint_id>

   Answer:

       <breakpointEnabled bp_id="<id>"/>

   Example:

       C: enable 2
       A: <breakpointEnabled bp_id="2"/>

### 2.1.4 Disabling Breakpoint

Supported _*since*_ _ruby-debug-ide_ _*0.2.0*_

   Command:

       disable <breakpoint_id>

   Answer:

       <breakpointDisabled bp_id="<id>"/>

   Example:

       C: disable 2
       A: <breakpointDisabled bp_id="2"/>

### 2.1.5 Setting Condition on Breakpoint

Supported _*since*_ _ruby-debug-ide_ _*0.2.0*_

   Command:

       condition <script>:<line_no>

   Answer:

       <conditionSet bp_id="<id>"/>

   Example:

       C: condition 1 x>5   # Stop on breakpoint 1 only if x>5 is true.
       A: <conditionSet bp_id="1"/>

### 2.1.6 Exception Breakpoint

Command:

       catch <exception_class_name>

   Answer:

       <catchpointSet exception="<exception_class_name>"/>

   Example:

       C: catch ZeroDivisionError
       A: <catchpointSet exception="ZeroDivisionError"/>

### 2.1.7 Threads Listing

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

### 2.1.8 Frames Listing

Command:

       where

   Answer:

       <frames>
         <frame no="<frame_no>" file="<script>" line="<line_no>" current="<boolean>"/>
         <frame no="<frame_no>" file="<script>" line="<line_no>"/>
         ...
       </frames>

   Example:

       C: where
       A: <frames>
            <frame no="1" file="/path/to/test2.rb" line="3" current="true" />
            <frame no="2" file="/path/to/test.rb" line="3" />
          </frames>

### 2.1.9 Variables Listing

#### 2.1.9.1 Local Variables

Example:

       C: var local
       A: <variables>
            <variable name="array" kind="local" value="Array (2 element(s))" type="Array" hasChildren="true" objectId="-0x2418a904"/>
          </variables>

#### 2.1.9.2 Instance Variables

Example:

       C: var instance some_array
       A: <variables>
            <variable name="[0]" kind="instance" value="1" type="Fixnum" hasChildren="false" objectId="+0x3"/>
            <variable name="[1]" kind="instance" value="2" type="Fixnum" hasChildren="false" objectId="+0x5"/>
          </variables>


       C: var instance some_object
       A: <variables>
            <variable name="@y" kind="instance" value="5" type="Fixnum" hasChildren="false" objectId="+0xb"/>
          </variables>

2.2 Events
----------

### 2.2.1 Breakpoint

Event example:

       <breakpoint file="test.rb" line="1" threadId="1"/>

### 2.2.2 Suspension

Event example:

       <suspended file="/path/to/test.rb" line="2" threadId="1" frames="1"/>

### 2.2.3 Exception

Event example:

       <exception file="/path/to/test.rb" line="2" type="ZeroDivisionError" message="divided by 0" threadId="1"/>

### 2.2.4 Message

Event example:

       <message>some text</message>
       <message debug='true'>some debug text</message>

3 Changes
=========

Mentions also related changes in the _ruby-debug-ide_ gem
implementation.

3.1 Changes between 0.4.9 and 0.4.10
------------------------------------

   * Fixes possible NoSuchMethodException

3.2 Changes between 0.4.5 and 0.4.6
-----------------------------------

   * added Debugger::start_server (ticket #25972)

3.3 Changes between 0.4.4 and 0.4.5
-----------------------------------

   * possibility to remove catchpoints

   * bugfix: syntax error with Ruby 1.9

3.4 Changes between 0.4.3 and 0.4.4
-----------------------------------

   * bugfix: print out backtrace when debuggee fails

3.5 Changes between 0.4.2 and 0.4.3
-----------------------------------

   * depends on the "~> 0.10.3.x", rather then on 0.10.3 exactly to be
     compatible with future ruby-debug-base 0.10.3.x releases

3.6 Changes between 0.4.1 and 0.4.2
-----------------------------------

   * Dependency changed to ruby-debug-base-0.10.3 which fixes various
     bugs   and contains bunch of RFEs

3.7 Changes between 0.4.0 and 0.4.1
-----------------------------------

   * '-stop' switch: stop at the first line when the script is loaded.
      Utilized by remote debugging

   * Making '-x' switch actually work. Commenting out sending of <trace>
      elements to the debugger. To be decided. There are large amount
     of such   events. For now serves rather for ruby-debug-ide
     developers.

   * ensure 'file' attribute contains absolute path

   * fixing CLI verbose when -d is used. Some unused code

3.8 Changes between 0.3.1 and 0.4.0
-----------------------------------

   * Support for debug attribute in message element. Emitted by
     backend when -xml-debug (new since 0.4.0) option is used.

   * More robust failures handling in DebugThread

3.9 Changes between 0.3.4 and 0.3.5
-----------------------------------

   * bugfix: syntax error with Ruby 1.9

3.10 Changes between 0.3.3 and 0.3.4
------------------------------------

   * bugfix: print out backtrace when debuggee fails

3.11 Changes between 0.3.2 and 0.3.3
------------------------------------

   * depends on the "~> 0.10.3.x", rather then on 0.10.3 exactly to be
     compatible with future ruby-debug-base 0.10.3.x releases

3.12 Changes between 0.3.1 and 0.3.2
------------------------------------

   * Dependency changed to ruby-debug-base-0.10.3 which fixes various
     bugs   and contains bunch of RFEs

3.13 Changes between 0.3.0 and 0.3.1
------------------------------------

   * Support for _-load-mode_ option. Hotfix, likely workaround, for
     GlassFish debugging. Experimental, might be removed in the future.
     If option   is used, it calls Debugger#debug_load with
     increment_start=true

3.14 Changes between 0.2.1 and 0.3.0
------------------------------------

   * *Note Catchpoint:: now answers with <conditionSet> instead of just
      <message> providing better control at frontend side

   * Dependency changed to ruby-debug-base-0.10.2

   * Bugfixes (see ChangeLog)

3.15 Changes between 0.2.0 and 0.2.1
------------------------------------

   * Hotfixing/workarounding problem with connection on some Mac OSes,
     see Debugger timing out
     (http://ruby.netbeans.org/servlets/BrowseList?list=users&by=thread&from=861334)
     thread.

3.16 Changes between 0.1.10 and 0.2.0
-------------------------------------

### 3.16.1 New Features

   * *Note Condition::

   * *Note Enabling Breakpoint::

   * *Note Disabling Breakpoint::

### 3.16.2 Uncompatible Changes

   * _catch off_ does not work anymore, since _ruby-debug-base_s
     support multiple catchpoints since 0.10.1, not just one.
     *Note:* however _ruby-debug-base_s in version 0.10.1 suffers with
      bug
     (http://rubyforge.org/tracker/index.php?func=detail&aid=20237&group_id=1900&atid=7436)
       that it is not possible to remove catchpoints. So catchpoints
     removing must    be workarounded in higher layers. The bug is
     fixed in _ruby-debug-base_s    0.10.2 and above.

