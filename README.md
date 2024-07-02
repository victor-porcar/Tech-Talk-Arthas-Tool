# TechTalk: Arthas Tool

This is an overview of the [Arthas](https://arthas.aliyun.com/en/) tool, which is a complete set of diagnostic tools to troubleshoot JVM issues on the fly. 

It is an open source project by Alibaba.   → GitHub [here](https://github.com/alibaba/arthas)

The doc is available [here](https://arthas.aliyun.com/en/doc)<br/>

 - [Introduction](#introduction)
 - [Usage](#usage)
 - [Typical USE CASES](#typical-use-cases):
     - [Change CLASS definition on the fly](#change-class-definition-on-the-fly)
     - [Intercept calls to a method and show PARAMS, RETURN value and EXCEPTIONS](#intercept-calls-to-a-method-and-show-params-return-value-and-exceptions)
     - [Inspect / Set object variable value](#inspect--set-object-variable-value)  
     - [Invoke method](#invoke-method)  
     - [Profile invocation of a method](#profile-invocation-of-a-method)
     - [Force GC](#force-gc)
 - [Appendix: Using Kubernetes](#appendix--using-kubernetes)
 

<br/>
<br/>

## Introduction

Arthas allows developers to troubleshoot production issues for Java applications without modifying code or restarting servers.</br>

So it helps developers to address scenarios like the following:

* There is an error in production under particular conditions, If I could add more log I would be able to see what is going on ! 
* I believe changing the logic in a method would fix a problem, but I can not test it until a full release cycle is performed and that is not possible now.
* I know this method fails but in order to know why and when I need to know the value of the parameter passed in a particular parameter.
* An instance variable value is set incorrectly, If I could change the value then I would be able to see whether that is the cause of a problem.
* I’d like to inspect the values of certain variables.
* I’d like to force a Garbage Collector.
* I’d like to profile a particular method to see where is the bottleneck.

 
Arthas process is “attached” to a given running Java application in a way that it can access and manipulate *transparently* the JVM running the Java app.</br>
NOTE: Arthas and the JVM must be running in the same machine. It does not allow to “attach” remotely.

 
Once attached, Arthas will offer a console to enter Arthas [commands](https://arthas.aliyun.com/en/doc/commands.html). There are more than 45 available, although in this tech talk only a small selection will be explained


 
## Usage
 
In order to use Arthas, download it and execute it in any environment running a JVM
```
curl -O https://arthas.aliyun.com/arthas-boot.jar
java -jar arthas-boot.jar   
```
Once executed, there will be a prompt to select the desired JVM
```
 
[INFO] JAVA_HOME: /usr/lib/jvm/java-8-openjdk-amd64/jre
[INFO] arthas-boot version: 3.7.2
[INFO] Found existing java process, please choose one and input the serial number of the process, eg : 1. Then hit ENTER.
* [1]: 130961 org.gradle.launcher.daemon.bootstrap.GradleDaemon
  [2]: 131521 com.test.SearchApplication
  [3]: 14026 com.intellij.idea.Main

```
Now you have to choose one of the JVM, once selected, the Arthas console will appear:

```
2
[INFO] arthas home: /home/victor.porcar/.arthas/lib/3.7.2/arthas
[INFO] Try to attach process 131521
ws_powersearch2/capability-iris 
                          -sdp-search/service-iris-sdp-search/build/classes/java/main:/h 
                          ome/victor.porcar/workspaces/ws_powersearch2/capability-iris-s 
                          dp-search/service-iris-sdp-search/build/resources/main:/home/vPicked up JAVA_TOOL_OPTIONS: 
[INFO] Attach process 131521 success.
[INFO] arthas-client connect 127.0.0.1 3658
  ,---.  ,------. ,--------.,--.  ,--.  ,---.   ,---.                           
 /  O  \ |  .--. ''--.  .--'|  '--'  | /  O  \ '   .-'                          
|  .-.  ||  '--'.'   |  |   |  .--.  ||  .-.  |`.  `-.                          
|  | |  ||  |\  \    |  |   |  |  |  ||  | |  |.-'    |                         
`--' `--'`--' '--'   `--'   `--'  `--'`--' `--'`-----'                          

wiki       https://arthas.aliyun.com/doc                                        
tutorials  https://arthas.aliyun.com/doc/arthas-tutorials.html                  
version    3.7.2                                                                
main_class                                                                      
pid        131521                                                               
time       2024-06-06 10:12:27                                                  


```
Then from the console you can use any Arthas commands

for example one of the simplest ones is `jvm`command that will show information of the JVM context
```
[arthas@36030]$ jvm
 RUNTIME                                                                                 
-----------------------------------------------------------------------------------------
 MACHINE-NAME             36030@VPC00560                                                 
 JVM-START-TIME           2024-06-27 09:14:40                                            
 MANAGEMENT-SPEC-VERSION  1.2                                                            
 SPEC-NAME                Java Virtual Machine Specification                             
 SPEC-VENDOR              Oracle Corporation                                             
 SPEC-VERSION             1.8                                                            
 VM-NAME                  OpenJDK 64-Bit Server VM                                       
 VM-VENDOR                Private Build                                                  
 VM-VERSION               25.412-b08                                                     
 INPUT-ARGUMENTS          -Dfile.encoding=UTF-8                                          
                          -Duser.country=GB                                              
                          -Duser.language=en                                             
                          -Duser.variant                                                 
 CLASS-PATH               ....
 
< MORE INFORMATION .....>
Change CLASS definition on the fly
```
NOTE: **Once we have finished our work in Arthas, it is very important to CLOSE its process by using command `stop`**
<br/><br/>
```
[arthas@299291]$ stop
Resetting all enhanced classes ...
Affect(class count: 0 , method count: 0) cost in 1 ms, listenerId: 0
Arthas Server is going to shutdown...
[arthas@299291]$ session (c0138352-a90e-4d55-b3d0-a8fb5aafda65) is closed because server is going to shutdown.

```

If the **stop** command can not be applied for any reason, Arthas can be closed manually by killing its process
 
```
ps -ef | grep 'java -jar arthas-boot.jar'
kill <PID> 
```
<br/>
<br/>

## Typical Use Cases
 
<br/>
<br/>

### Change CLASS definition on the fly

In order to change the definition of a class on the fly, Arthas offers command [`retransform`](https://arthas.aliyun.com/en/doc/retransform.html)

steps:
1) regenerate the new version of the class you wish to change using your IDE locally. If that is not possible, then generate new artifact as rar and unzipped it to find the corresponding class file.
2) copy class file in any folder
3) execute Arthas -> `java -jar arthas-boot.jar` and use the command retransform
```
[arthas@10]$ retransform <FOLDER>/MyClass.class
[arthas@10]$ stop
```
NOTE 1: There are some restrictions:
* the new version of the class can not have more or less methods that the original and methods can not change their signatures. in other words, it is allowed to change only the "body" of the methods, otherwise a exception like this would happen: `retransform error! java.lang.UnsupportedOperationException: class redefinition failed: attempted to add a method`
* The new class can not add or delete instance or static attributes

NOTE 2: this technique can be useful to add more logs or change the logic in a particular method.

<br/>
<br/>

### Intercept calls to a method and show PARAMS, RETURN value and EXCEPTIONS

Before explaining how to do it using command watch, it is worth to mention that params, return value and exceptions can be examined by adding proper log lines using the previous technique to change class definition "on the fly".

Now, let's see how to do it using command [watch](https://arthas.aliyun.com/en/doc/watch.html): let's suposse there is a function in class (com.test.MyClass) which is called from time to time

```java

    public  int myMethod(String customer, List<String> list) throws IOException {
         int returnValue = list.size();
         String joinString = String.join(" - ", list);
         int sizeJoinString = joinString.length() + customer;
         return sizeJoinString;
    }
```

The following Arthas command will show for each invocation (grouped in seconds) all the params, returned object and exception (if exist) 

```
[arthas@10]$ watch com.test.MyClass myMethod '{params[0],params[1],returnObj,throwExp}' -x 2
[arthas@10]$ stop
```
where in this case:

*params[0]* -> first parameter passed to the method<br/><br/>
*params[1]* -> second parameter passed to the methdp<br/><br/>
*returnObj* -> returned value (null if the method return void)<br/><br/>
*throwExp*  -> launched exception (if any)<br/><br/>


then the outcome would be like:

```

method=com.test.MyClass.myMethod location=AtExit
ts=2024-06-05 13:43:17; [cost=0.024663ms] result=@ArrayList[
    @String[1100075],             <---------- THIS MEANS that first parameter is a String with value 1100075
    @ArrayList[                   <---------- THIS MEANS that second parameter is a list with two parameters   
        @String[hola],
        @String[caracola],
    ],
    @Integer[15],                <---------- THIS MEANS return value is 15
    null,                        <---------- THIS MEANS THERE IS NO EXCEPTION
]



```

Now let's assume the second parameter of the method (the list) is null
let's execute the same arthas command
 
the result would be
```
method=com.test.MyClass.myMethod location=AtExceptionExit
ts=2024-06-05 13:45:42; [cost=0.037923ms] result=@ArrayList[
    @String[1200002],
    null,
    null,
    java.lang.NullPointerException
	at com.test.MyClass.myMethod(Test.java:264)
	at com.test.MyClass.lambda$getCallableForThread$0(Test.java:213)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:750)
,
]
```
 In order to intercept only when a condition is matched (in this case first parameter "customer" equals to "1100009"
```
[arthas@10]$ watch com.test.MyClass myMethod '{params[0],params[1],returnObj,throwExp}'  'params[0] eq 1100009' -x 2
[arthas@10]$ stop
```



### Inspect / Set object variable value 


#### Instance variable

Let's assume there are several objects of the following class

```java
package com.test

Class MyClass {
  public String a;
  public String b;
  public List<String> getList() {
      ....
  }
}

``` 
 
The command [vmtool](https://arthas.aliyun.com/en/doc/vmtool.html) allows to inspect / set objects of this Class (instances) and its attributes



**INSPECT**

To begin with, the following command shows the content of the first 100 objects found of class MyClass  (with no particular order): 

 ```
[arthas@10]$ vmtool --action getInstances -className com.test.MyClass -limit 100
[arthas@10]$ @MyClass[][
[arthas@10]$     @MyClass[MyClass(a=Knowledge, b=Culture)],
[arthas@10]$     @MyClass[MyClass(a=Folk, b=Culture)],
[arthas@10]$     @MyClass[MyClass(a=Sports, b=Programmes)],
[arthas@10]$  ....
[arthas@10]$ stop
```

Actually it returns a list of objects, it is possible to refer to one, for example the first one. This case is useful to deal with Singletons, for example all managed beans by default in Spring are Singleton

 ```
[arthas@10]$ vmtool --action getInstances -className com.test.MyClass --express 'instances[0]'
[arthas@10]$ @MyClass[][
[arthas@10]$     @MyClass[MyClass(a=Knowledge, b=Culture)],
[arthas@10]$ ]
[arthas@10]$ stop
```
Please note that the --express parameter value is a [OGNL](https://commons.apache.org/dormant/commons-ognl/) expression, which offers a powerful way to operate with objects and its attributes in this context

For example the following command will filter all objects of MyClass having `b` attribute equals to "Culture"

` vmtool --action getInstances -className com.test.MyClass --express 'instances.{? #this.b.equals("Culture")}'`

NOTE: 
 
> `instances.{? #this.b.equals("Culture")}` <br/>
> can be seen as the Java expression: <br/>
> `instances.stream().filter(x->x.equals("Culture)).collect(Collectors.toList())` <br/>

<br/>

Following this, if it is required to get the value of `a` attribute of those objects then:

`vmtool --action getInstances -className com.test.MyClass --express 'instances.{? #this.b.equals("Culture")}.{#this.a}'`



**SET**

The following command will set the value "Horror" to the attribute `a` to all objects of MyClass having it `b` attribute with value "Culture"

`vmtool --action getInstances -className com.test.MyClass --express 'instances.{? #this.b.equals("Culture")}.{#this.a="Horror"}'`

If the value were private, it is required to execute the following command before setting the variable
```
[arthas@10]$ options strict false
 
```
<br/>

 #### Static variable
 
**INSPECT**

use @ognl command expression as follows:
 ```
[arthas@10]$ ognl '@com.test.MyClass@STATIC_VARIABLE' 
[arthas@10]$ @Boolean[false]
[arthas@10]$ stop
```

**SET**

*TODO*
 
<br/>
<br/>

### Invoke method

#### Instance method

It works similarly to inspect variables:

 
```
[arthas@10]$ vmtool --action getInstances  --className com.test.MyClass --express 'instances[0].getList()'
[arthas@10]$ stop
```
Let's assume that the method has parameters: 
<br/>
`public List<String> getList(List<String> ids, Instant instant,  Boolean stbView, String lang)`

then the following would be an example of invocation

```
[arthas@10]$ vmtool --action getInstances  --className com.test.MyClass --express 'instances[0].getList({"87164","98989"}, @java.time.Instant@ofEpochSecond(1713825471),false, "SPA")'
[arthas@10]$ stop
```

#### Static method

Use directly ongl command

```
[arthas@10]$ ognl '@com.test.MyClass@myStaticMethod()'
[arthas@10]$ stop
```

<br/>
<br/>

### Profile invocation of a method

Command [trace](https://arthas.aliyun.com/en/doc/trace.html) is useful to help discovering and locating the performance flaws in your system.
<br/>
Given a method, it shows the total execution time of other methods called from inside of it.
<br/>
NOTE: It can only trace the first level method call each time.
<br/>
For example, given the following class

```java
package com.test;
public class MyClass {

    public void go() {
        // some code
        method1();
        // some code
        method2();
        // some code
        method3();
        // some code
    }
...
}
```

The following trace command profiles `go()`  invocations, 
it shows all executions of the method (in the screenshot it shows three executions)

```
[arthas@10]$ [arthas@10]$ trace com.test.MyClass go
[arthas@10]$ stop
```
![image](./images/arthas_profile_3.jpeg)

NOTE: The #6, #8 and #10 indicates the line in source code

<br/>
<br/>

### Force GC
 
The command vmtool can force the GC as follows:
 
```
[arthas@10]$ vmtool --action forceGc
[arthas@10]$ stop
```

<br/>
<br/>

## Appendix:  Using Kubernetes

I've created a couple of scripts useful to apply Arthas in a Kubernetes environment

### [kubernetes_arthas_execution.sh](./scripts/kubernetes_arthas_execution.sh)

It allows to apply a Arthas command to all pods belonging to the given "<KUBERNETES_NAMESPACE>" and having <POD_NAME_PATTERN> as part of its name

```
kubernetes_arthas_execution.sh "<KUBERNETES_NAMESPACE>" "<POD_NAME_PATTERN>" "<ARTHAS_COMMAND>"
```

for example, let's suppose there are the following pods:

```
$ kubectl get pods --namespace "my-namespace" | grep "service-search"

service-search-7ddffdcf5b-l9gdz           1/1     Running     0         2d19h
service-search-587f749bbc-vlbcr           1/1     Running     0         2d19h

```

The following script would apply the arthas command to execute a method to both pods:

```
./scripts/kubernetes_arthas_execution.sh "my-namespace" "service-search" "vmtool --action getInstances  --className tcom.test.MyClass --express instances[0].getList();stop"
```

### [kubernetes_file_upload.sh](./scripts/kubernetes_file_upload.sh)

It allows to upload a file to all pods belonging to the given "<KUBERNETES_NAMESPACE>" and having <POD_NAME_PATTERN> as part of its name

```
./scripts/kubernetes_file_upload.sh "<LOCAL_PATH_FOR_FILE>" "<KUBERNETES_NAMESPACE>" "<POD_NAME_PATTERN>" "<POD_PATH_FOR_FILE>"
```

It is useful to change class on the fly <br/>

For example:

```
kubernetes_file_upload.sh "/home/victor.porcar/workspaces/my_service/build/classes/java/main/com/test/MyClass.class" "my-space" "service-search" "/tmp"
kubernetes_arthas_execution.sh "my-space" "service-search" "retransform/tmp/MyClass.class;stop"
```


<br/>
<br/>



