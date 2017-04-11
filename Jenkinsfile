pipeline {
  agent any
  stages {
    stage('Clean') {
      steps {
        sh 'rm -rf paperclip.jar paperclip-*.jar Paper-Server/ Paper-API/ work/Spigot/Spigot-API work/Spigot/Spigot-Server'
      }
    }
    stage('Apply Patches') {
      steps {
        sh '''git config --global user.name "Godzilla"
git config --global user.email "jenkins@ci.destroystokyo.com"
./paper patch
git tag -a $BUILD_NUMBER -m "Jenkins build $BUILD_NUMBER"'''
      }
    }
    stage('Build') {
      steps {
        sh 'mvn clean install'
      }
    }
    stage('Package') {
      steps {
        sh '''basedir=$(dirname "$SOURCE")
./scripts/paperclip.sh "$basedir"
ln -s paperclip.jar paperclip-$BUILD_NUMBER.jar'''
      }
    }
    stage('Archive') {
      steps {
        archiveArtifacts(fingerprint: true, onlyIfSuccessful: true, artifacts: 'paperclip*.jar')
      }
    }
  }
}