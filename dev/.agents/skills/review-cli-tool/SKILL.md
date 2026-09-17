---
name: review-cli-tool
description: Read and answer local code review comments left with the "review" command. Use when the user asks to address review comments or review feedback, to look at unresolved comments on a change, or to reply to or resolve review threads. Also use when a task mentions the review tool, review threads, or snapshots of a change.
---

# Answering review comments

The review command holds code review comments for the commits in this
repository. A human reviewer leaves comments in a web interface; you read
them from the command line, fix what they ask for, and reply.

The loop:

 1. Read the open comments:

        review comments

    Each thread is printed with its number in brackets, the file and line
    it is attached to as that file stands now, the code it was written
    against, and the comments themselves.

    Those two are deliberately different. Comments are written against a
    snapshot of the change, which is often older than the code in front of
    you, so the line has usually moved. The heading gives the line as it
    is now, which is where to make the change; the context below it is the
    text as the reviewer saw it, which is what the comment means. Reading
    a comment beside code the reviewer never saw is how you misread it.

    The heading says "written at line N" when the line has moved, and
    "now gone" when the code it was attached to has been deleted. In that
    case the context is the only record of what was meant, so read it
    carefully before deciding what the comment was about.

    Only published comments are listed. Drafts are the reviewer's
    unfinished thoughts: do not act on them, and do not pass -drafts.

    Text is usually the easier form to read. Pass -json if you would
    rather parse it: "current_line" is the line as it is now, "line" is
    the line it was written at, "context" is the snapshot's text numbered
    by that older line, and "stale" says the line has gone. Use -c to
    change how much context is shown.

 2. Fix what each thread asks for, editing the code as you normally would.
    Amending the commit is expected; comments survive it.

    In a jj repository, make the fix in a new commit on top of the one it
    belongs to, and fold it in once it is right:

        jj new K          # K is the change the comment is on
        ... edit files ...
        jj squash         # fold the fix into K

    Not "jj edit K". That makes K itself the working copy and rewrites it
    with every file you save, so a fix that turns out wrong has to be
    dug back out of the operation log. With "jj new" the fix sits in a
    commit of its own until you squash it, and abandoning it costs one
    command:

        jj abandon        # throw the fix away, K untouched

    Squashing rebases whatever is stacked above K, which was going to
    happen anyway, and K keeps its change ID, so its comments stay put.

    Work through the commits from the oldest to the newest, not in the
    order the comments happen to be printed in. Later commits are stacked
    on the ones before them, so a fix to an early commit is rebased
    through everything above it; fixing a later one first only means
    doing that work twice, and can leave conflicts to untangle in between.

 3. Reply to every thread you acted on, by its number:

        review reply -resolve 12 'Renamed to parseHeader.'

    -resolve closes the thread. Replies made from the command line are
    always marked as not coming from the reviewer, so the web interface
    can draw them apart from their own comments, and are recorded as from
    "agent" unless you give a name:

        review reply -from claude -resolve 12 'Renamed to parseHeader.'

    Resolve only what you actually fixed. If a comment asks for a judgement
    call, a design decision, or anything you are unsure about, reply
    without -resolve and say what you need:

        review reply 12 'Could go two ways here: ... which do you prefer?'

    Ask through the review, not in conversation. A question about a
    comment belongs in a reply on that thread, where the reviewer reads it
    beside the code and the comment it is about; asked in conversation it
    arrives with none of that. So do not stop and put the question to the
    user: leave the thread unresolved and go on to the next one. Waiting
    on an answer to one comment is no reason to leave the other twenty
    untouched, and by the time the answer comes everything else is done.

    Omitting the text reads the reply from standard input, which is easier
    for replies of more than a line.

 4. Once you have finished all the threads, record a snapshot, once:

        review snapshot

    That gives the reviewer a point to compare against, so they can see
    exactly what you changed since they commented. Do not snapshot after
    each individual fix.

 5. Say what you did, briefly: what you fixed and resolved, and which
    threads you left open and why. That is a summary of work already
    finished, not a question waiting on an answer.

Rules:

  - Never resolve a thread you did not address.
  - Never stop the work to ask about a comment. Reply on its thread,
    leave it unresolved, and carry on with the rest.
  - Never speak for the reviewer. Do not publish their drafts; "review
    publish" is theirs to run.
  - When a comment's line is gone, work out from the text it was written
    against what it referred to, and say in your reply what you concluded.
  - If you cannot work out what a comment refers to, reply asking, rather
    than guessing and resolving.

Other commands that may be useful:

    review comments CHANGE   comments on one change only
    review comments -all     include threads already resolved
    review snapshots         list the snapshots of each change

When you have been asked to review the code rather than to answer comments
on it, you can start a thread of your own, at the line it is about:

    review add CHANGE file.go:42 'This drops the error from Close.'

Use it only when reviewing is the task. While you are working through
someone else's comments, reply to them; a new thread there is a remark
addressed to nobody.
