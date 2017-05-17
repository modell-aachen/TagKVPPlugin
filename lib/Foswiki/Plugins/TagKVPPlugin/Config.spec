# ---+ Extensions
# ---++ TagKVPPlugin
# **STRING**
# This condition must be true, in order to allow tagging the topic:
# <p>Note: the <i>$TOPIC allows 'CHANGE' condition</i> takes care of topics outside the workflow.</p>
$Foswiki::cfg{Plugins}{TagKVPPlugin}{condition} = '%IF{"$TOPIC allows \'CHANGE\' and $\'WORKFLOWALLOWS{allowtagging}\'" then="1" else="0"}%';

