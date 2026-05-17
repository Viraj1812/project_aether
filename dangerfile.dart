import 'package:danger_core/danger_core.dart';
import 'package:danger_core/src/models/gitlab_dsl.dart';

void main() {
  //! ---------  Danger Dart Error Message ----------------
  const String envContain = 'You pushed .env file.';
  const String prWip = 'PR is considered WIP.';
  const String descriptionShort = "This PR's description is too short. It should be contain at least 30 characters.";
  const String titleShort = "This PR's title is too short. It should be contain at least 15 characters.";
  const String noAssignee = 'There are no assignees to this pull request.';
  const String prShort =
      'This PR size is too large Over 15 files. Please split into separate PRs to enable faster & easier review.';
  const String removeBranch = 'Should have deleted the source branch. Please fill the checkbox.';
  const String pubLockContain =
      'If there are any changes to the pubspec.yaml file, the pubspec.lock file should also be present.';
  const int minimumLengthDescription = 30;
  const int minimumLengthTitle = 15;
  const int maximumPRFiles = 15;

  checkEnv(envContain);
  prWorkInProgress(prWip);
  checkTitle(minimumLengthTitle, titleShort);
  checkDescription(minimumLengthDescription, descriptionShort);
  checkAssignees(noAssignee);
  checkPRFiles(maximumPRFiles, prShort);
  checkRemoveBranch(removeBranch);
  checkPubLock(pubLockContain);
}

//!---- Env file check
void checkEnv(String envContain) {
  final List<String> dangerGitFiles = <String>[
    ...danger.git.createdFiles,
    ...danger.git.modifiedFiles,
  ];

  final bool envFile = dangerGitFiles.any((String file) => file == '.env');
  if (envFile) {
    fail(envContain);
  }
}

//! Pub.lock file check
void checkPubLock(String pubLockContain) {
  final bool isContainPubYml = danger.git.modifiedFiles.any((String file) => file == 'pubspec.yml');
  final bool isContainPubLock = danger.git.modifiedFiles.any((String file) => file == 'pubspec.lock');

  if (isContainPubYml && isContainPubLock) {
    fail(pubLockContain);
  }
}

//! --- PR WIP
void prWorkInProgress(String prWip) {
  if (danger.gitLab.mergeRequest.title.contains('wip')) {
    fail(prWip);
  }
}

//! --- title length
void checkTitle(int minimumLength, String titleShort) {
  final bool titleIsValid = danger.gitLab.mergeRequest.title.length >= minimumLength;

  if (!titleIsValid) {
    fail(titleShort);
  }
}

//! ---- description length
void checkDescription(int minimumLength, String descriptionShort) {
  final bool descriptionIsLongEnough = danger.gitLab.mergeRequest.description.length >= minimumLength;

  if (!descriptionIsLongEnough) {
    fail(descriptionShort);
  }
}

//! --- check assignees
void checkAssignees(String noAssignee) {
  final bool hasAssignees = danger.gitLab.mergeRequest.assignee?.name.isNotEmpty ?? false;

  if (!hasAssignees) {
    fail(noAssignee);
  }
}

//! --- checking PR size
void checkPRFiles(int maximumPRFiles, String prShort) {
  final GitLabMergeRequest mergeRequest = danger.gitLab.mergeRequest;
  final int changeCount = mergeRequest.changesCount.length;
  final bool devBranch = mergeRequest.sourceBranch == 'development';

  if (!devBranch) {
    if (changeCount > maximumPRFiles) {
      fail(prShort);
    }
  }
}

//! --- check Remove Branch
void checkRemoveBranch(String removeBranch) {
  final bool isRemoveBranch = danger.gitLab.mergeRequest.forceRemoveSourceBranch ?? false;

  if (!isRemoveBranch) {
    warn(removeBranch);
  }
}
