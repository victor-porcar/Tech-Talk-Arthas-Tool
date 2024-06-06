# Arthas Cheatsheet
This is a cheat sheet for the [Arthas](https://github.com/alibaba/arthas) tool 

## Introduction

[Arthas](https://github.com/alibaba/arthas) is a complete set of diagnostic tools to troubleshoot JVM issues on the fly.  

In order to use it, download it and execute it in any environment running a JVM
```
curl -O https://arthas.aliyun.com/arthas-boot.jar
java -jar arthas-boot.jar   
```
`arthas-boot.jar` will detect all running JVM and will allow you to select one
```
victor.porcar@CAS00560:~/arthas$ java -jar arthas-boot.jar
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
Picked up JAVA_TOOL_OPTIONS: 
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
Then from the console you can use the Arthas commands

NOTE: **Once we have finished our work, it is very important to CLOSE the arthas console by using command `stop`**
<br/><br/>


## Typical USE CASES

### Intercept calls to a method and show PARAMS, RETURN value and EXCEPTIONS (if thrown)

To do this we'll use `watch` command Let's assume this function in class (com.test.MyClass) which is called very often

```java

    public  int myMethod(String customer, List<String> list) throws IOException {
         int returnValue = list.size();
         String joinString = String.join(" - ", list);
         int sizeJoinString = joinString.length() + customer;
         return sizeJoinString;
    }
```



The following command will show for each invocation (grouped in seconds) all the params, returned object and exception (if exist) 

```
watch com.test.MyClass myMethod '{params[0],params[1],returnObj,throwExp}' -x 2
```

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
watch tv.mirada.iris.user.profile.Test httpClient '{params[0],params[1],returnObj,throwExp}'  'params[0] eq 1100009' -x 2
```

### ver variable de una clase (singleton) o instancia (buscar la instancia de la clase)
TODO



### ver tiempos de ejecución de un metodo
TODO


### invocar un metodo (instancia o clase)
TODO


### cambiar clase en caliente

TODO


