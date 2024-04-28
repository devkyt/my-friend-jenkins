<p>
  <img src="img/header/jenkins-black.png#gh-dark-mode-only" alt="image" height="100" style="margin-bottom: 5px"/>
  <img src="img/header/jenkins-white.png#gh-light-mode-only" alt="image" height="100" style="margin-bottom: 5px"/>
</p>

# Annotation <!-- omit in toc -->
I've created this repo as a Jenkins cheat sheet for myself. Cause, god knows why, my brain isn't perfect 
and I keep forgetting even obvious things. But at the same time, I always, like always remember the dumb jokes from "The Office" and "Rush Hour". 

So, long story short, it will be really awesome if you find here something useful. 

# Table of Contents <!-- omit in toc -->
- [Deploy to Kubernetes](#deploy-to-kubernetes)
- [Authenticate with GitHub App](#authenticate-with-github-app)
  - [Create Github App](#create-github-app)
  - [Generate private key for auth to the GitHub App](#generate-private-key-for-auth-to-the-github-app)
  - [Install App to your account](#install-app-to-your-account)
  - [Add App creds to Jenkins](#add-app-creds-to-jenkins)
  - [Access GitHub Repos from Pipeline](#access-github-repos-from-pipeline)
- [Mulitbracnh pipeline](#mulitbracnh-pipeline)
  - [Create Multibranch pipeline for GitHub private repo](#create-multibranch-pipeline-for-github-private-repo)
- [Environment](#environment)
  - [Add global env variables](#add-global-env-variables)
  - [Set env variables in Pipeline](#set-env-variables-in-pipeline)
- [Jobs](#jobs)
  - [Basic definition](#basic-definition)
  - [Add agent manifest directly to the pipeline](#add-agent-manifest-directly-to-the-pipeline)
  - [Load an agent manifest from YAML](#load-an-agent-manifest-from-yaml)
  - [Set default container for the pipeline](#set-default-container-for-the-pipeline)
  - [Add input parameters for the pipeline](#add-input-parameters-for-the-pipeline)
  - [Trigger pipeline from remote](#trigger-pipeline-from-remote)
  - [Trigger pipeline on the event in GitHub repo](#trigger-pipeline-on-the-event-in-github-repo)
  - [Specify action based on the pipeline's status](#specify-action-based-on-the-pipelines-status)
- [Examples of the real-world pipelines](#examples-of-the-real-world-pipelines)

## Deploy to Kubernetes
You can use my handcrafted Helm Chart to deploy Jenkins to the cluster:
```sh
helm upgrade --instal jenkins ./helm/ -f ./helm/vars.yaml --namespace=jenkins-ci
```
It's pretty simple and self-described. Feel free not only to change the values but also to adjust the Chart to your needs.


## Authenticate with GitHub App
So let's do this step by step starting from scratch.

### Create Github App
First, you need to create the GitHub App. Open GitHub and navigate to Settings. From there go to Developer Settings -> GitHub App -> New GitHub App.



https://github.com/devkyt/my-friend-jenkins/assets/96535499/87084ec9-9c13-41be-9596-409cbfbbab4a



Perform the next actions:
- Fill the "App Name" and "Description" fields
- Put your account URL on GitHub in the "Homepage URL" field
  



https://github.com/devkyt/my-friend-jenkins/assets/96535499/f1cbb504-1584-43ff-9efc-ee8a6c98f17c





- Put your Jenkins instance URL with path "/github-webhook" to the "Webhook URL"




https://github.com/devkyt/my-friend-jenkins/assets/96535499/ead6cba0-aae7-4ffc-807e-3c2f996885c4




- Grant next repo permissions:
    - Administration: Read-only
    - Checks: Read & write
    - Contents: Read & write
    - Metadata: Read-only
    - Pull requests: Read-only
- Subscribe to the following events:
    - Check run
    - Check suite
    - Pull request
    - Push
    - Repository
- In the "Where can this GitHub App be installed?" block choose:
  - "Only on this account" if you want to install the app only for the current org
  - "Any account" if you want to use it elsewhere (for the multiple org maybe)
- Click the "Create GitHub App" Button 




### Generate private key for auth to the GitHub App
Go again to the GitHub Apps in your org "Developer Settings" and press "Edit" on the created app. Under Private keys, select "Generate a private key" and download the key.




https://github.com/devkyt/my-friend-jenkins/assets/96535499/777e9d75-9070-449b-95c2-b09221c36603




Convert key to acceptable for Jenkins format: ```openssl pkcs8 -topk8 -inform PEM -outform PEM -in github-key.pem -out converted-github-key.pem -nocrypt```




https://github.com/devkyt/my-friend-jenkins/assets/96535499/50b09c92-7807-4ffc-b0c8-67fd8c166889





### Install App to your account
Now it's time to install the app to your account. Last time, navigate to the "Edit" page for your GitHub App and choose "Install app" in the sidebar menu.
Then select the account where you wish to install the app and account repos to which you will grant permissions.




https://github.com/devkyt/my-friend-jenkins/assets/96535499/0c01bb9f-2e23-41f7-bd25-294fe59363fa



### Add App creds to Jenkins
The final counter is to save app creds to the Jenkins instance.
- Login to Jenkins
- Go to "Manage Jenkins" -> "Credentials" -> "Global"
- Select "Add Credentials"
- Choose GitHub App as the Kind
- Enter your GitHub App Name in the "ID" field
- Enter your GitHub App ID in the "App ID" field
- Copy converted private key to the "Key" field
- Click "OK"

### Access GitHub Repos from Pipeline
Now you can read and write to your GitHub repos from Jenkins Pipelines:
```groovy
pipeline {

  agent {
    kubernetes {
      inheritFrom "slave"
      defaultContainer "jnlp"
    }
  }

  stages {
    stage("Get Code from Repo") {
      steps {
        withCredentials([usernamePassword(credentialsId: 'creds-id',
                                        usernameVariable: 'GITHUB_APP',
                                        passwordVariable: 'GITHUB_ACCESS_TOKEN')]) {
            checkout scmGit(
            branches: [[name: "master"]],
            userRemoteConfigs: [[url: "https://${GITHUB_APP}:${GITHUB_ACCESS_TOKEN}@github.com/org/repo.git"]])
    }
      }
    }

    stage("Change something") {
      steps {
        container("python") {
          sh """
          echo 'Make some changes'
          """
        }
      }
    }


    stage("Push Changes to Repo") {
      steps {
        container("jnlp") {
          withCredentials([usernamePassword(credentialsId: 'jenkins-stacktome',
                                            usernameVariable: 'GITHUB_APP',
                                            passwordVariable: 'GITHUB_ACCESS_TOKEN')]) {
          sh """
          git add .
          git commit -m 'yeah, it works'
          git push --set-upstream origin master
          """
          }
        }
      }
    }

  }

}
```

## Mulitbracnh pipeline
Jenkins Multibranch Pipeline is quite straitforward. It is a folder of Jobs which are defined in one repo but on different branches. 
So if you branch has a Jenkinsfile with pipeline script, Jenkins will automatically recognize it and create separate Job. 

### Create Multibranch pipeline for GitHub private repo

- Login to Jenkins and nn Dasboard click "Add New Item" button <br>
<img src='./img/multibranch/01.png' width=70% style="margin: 17px">

- Choose "Multibranch Pipeline" and enter a name for it <br>
<img src='./img/multibranch/02.png' width=70% style="margin: 17px">

- Fill the "Display name" and "Descriptions" fields if you want to
<img src='./img/multibranch/03.png' width=70% style="margin: 17px">

- In "Branch Sources" select GitHub <br>
<img src='./img/multibranch/04.png' width=70% style="margin: 17px">

- Choose existing GitHub App private key as a creds <br>
<img src='./img/multibranch/05.png' width=70% style="margin: 17px">

- Specify your repo URL <br>
<img src='./img/multibranch/06.png' width=70% style="margin: 17px">

- Adjust other options by your current needs <br>
<img src='./img/multibranch/07.png' width=70% style="margin: 17px">

- Leave "Build Configuration" unchanged <br>
<img src='./img/multibranch/08.png' width=70% style="margin: 17px">

- Save. If you didn't mess up, folder with your Pipelines should appear on Dashboard <br>
<img src='./img/multibranch/09.png' width=70% style="margin: 17px">

## Environment
### Add global env variables
From Jenkins Dashboard go to the Manage Jenkins an then to the System. Scroll down to the Global Properties. Check the Environment Variables box. 
Add key and value for env and save. Now you can use your env variable in all Pipelines like this:
```groovy
pipeline {

  agent {
    kubernetes {
      inheritFrom "slave"
      defaultContainer "jnlp"
    }
  }

  stages {
    stage("Access Global Env Var") {
      steps {
       sh "echo ${env.MY_GLOBAL_VAR}"
      }
    }
  }

}
```

### Set env variables in Pipeline 
You can define env vars specific to Pipeline using environment block in Job's definition:
```groovy
pipeline {

  agent {
    kubernetes {
      inheritFrom "slave"
      defaultContainer "jnlp"
    }
  }

  environment {
        USER = "Dwight Schrute"
        POSITION = "Assistant Regional Manager"
  }

  stages {
    stage("Access Pipeline Env Var") {
      steps {
        sh "echo ${USER} is ${POSITION}"
      }
    }
  }

}
```

## Jobs
### Basic definition
```groovy
pipeline {

  agent {
    kubernetes {
      inheritFrom "slave"
      yamlFile "Busybox.yaml"
    }
  }

  stages {

    stage("Write File in One Container") {
      steps {
        container("jnlp") {
          sh "echo Girl From Ipanema >> music.txt"
        }
      }
    }

    stage("Read File in Another Container") {
      steps {
        container("busybox") {
          sh "cat music.txt"
        }
      }
    }

  }
}
```

### Add agent manifest directly to the pipeline
```groovy
pipeline {

  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            app: busybox
        spec:
          containers:
          - name: busybox
            image: busybox:stable
            command:
            - sleep 3600
            tty: true
        '''
    }
  }

  stages {
    ...
  }

}
```


### Load an agent manifest from YAML
The YAML manifest for the agent must be located in the same directory as the Jenkinsfile:
```groovy
pipeline {

  agent {
    kubernetes {
      inheritFrom "slave"
      yamlFile "Node.yaml"
    }
  }

  stages {
    ...
  }

}
```


### Set default container for the pipeline
```groovy
pipeline {

  agent {
    kubernetes {
      inheritFrom "slave"
      defaultContainer "gke-toolkit"
      yamlFile "Node.yaml"
    }
  }

  stages {
    ...
  }

}
```

### Add input parameters for the pipeline
```groovy
pipeline {

  agent {
    kubernetes {
      inheritFrom "slave"
      defaultContainer "gke-toolkit"
      yamlFile "Node.yaml"
    }
  }

  parameters {
        string(name: 'BRANCH', defaultValue: 'staging', description: 'Branch to use')
        choice(name: 'ENVIRONMENT', choices: ['staging', 'production'], description: 'Where to deploy')
  }

  stages {
    ...
  }

}
```


### Trigger pipeline from remote


### Trigger pipeline on the event in GitHub repo

### Specify action based on the pipeline's status
```groovy
pipeline {

  agent {
    kubernetes {
      inheritFrom "slave"
      defaultContainer "gke-toolkit"
      yamlFile "Node.yaml"
    }
  }

  stages {
    ...
  }

  post {
    success {
      slackSend(color: "good", message: "Build completed: ${env.BUILD_URL}")
    }
    failure {
      slackSend(color: 'danger', message: "Build failed: ${env.BUILD_URL}")
    }
  }

}

```

## Examples of the real-world pipelines
Here you find some real-world examples of the Jenkins Jobs:
  - [Deploy Angular App](./pipelines/angular-app/)
  - [Deploy Scala App](./pipelines/scala-app/)
  - [Deploy Swagger UI](./pipelines/swagger/)
  - [Make Django DB Migrations](./pipelines/django-migrations/)









