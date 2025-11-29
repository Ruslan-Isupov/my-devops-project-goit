pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command: ["sleep", "99d"]
    - name: git
      image: alpine/git
      command: ["sleep", "99d"]
"""
    }
  }

  environment {
    ECR_REGISTRY = "155466261957.dkr.ecr.eu-central-1.amazonaws.com"
    IMAGE_NAME   = "django-app-repo-8"
    IMAGE_TAG    = "v1.0.${BUILD_NUMBER}"

    COMMIT_EMAIL = "jenkins@bot.com"
    COMMIT_NAME  = "Jenkins Bot"
  }

  stages {
    stage('Build & Push Docker Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context `pwd`/django \
              --dockerfile `pwd`/django/Dockerfile \
              --destination=$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG \
              --cache=true \
              --insecure \
              --skip-tls-verify
          '''
        }
      }
    }

    stage('Update Chart Tag in Git') {
      steps {
        container('git') {
          withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PAT')]) {
            sh '''
              # 1. Клонуємо репо
              git clone https://$GIT_USERNAME:$GIT_PAT@github.com/Ruslan-Isupov/goit-devops.git repo-temp
              
              # 2. Переходимо в папку
              cd repo-temp
              
              # 3. ВАЖЛИВО: Перемикаємося на вашу нову гілку
              git checkout lesson-8-9

              # 4. Оновлюємо тег
              cd charts/django-app
              sed -i "s/tag: .*/tag: \"$IMAGE_TAG\"/" values.yaml
              
              # 5. Комітимо і пушимо назад у ту саму гілку
              git config user.email "$COMMIT_EMAIL"
              git config user.name "$COMMIT_NAME"
              git add values.yaml
              git commit -m "Update image tag to $IMAGE_TAG [skip ci]"
              
              # ВАЖЛИВО: Пушимо в lesson-8-9
              git push origin lesson-8-9
            '''
          }
        }
      }
    }
  }
}