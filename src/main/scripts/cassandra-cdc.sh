#!/bin/bash

# Use Cassandra's init scripts to set up CLASSPATHs

if [ "x$CASSANDRA_INCLUDE" = "x" ]; then
    # Locations (in order) to use when searching for an include file.
    for include in "`dirname "$0"`/cassandra.in.sh" \
                   "$HOME/.cassandra.in.sh" \
                   /usr/share/cassandra/cassandra.in.sh \
                   /usr/local/share/cassandra/cassandra.in.sh \
                   /opt/cassandra/cassandra.in.sh; do
        if [ -r "$include" ]; then
            . "$include"
            break
        fi
    done
elif [ -r "$CASSANDRA_INCLUDE" ]; then
    . "$CASSANDRA_INCLUDE"
fi

if [ -z "$CLASSPATH" ]; then
    echo "You must set the CLASSPATH var" >&2
    exit 1
fi

# Add CDC jar to CLASSPATH
for jar in "`dirname "$0"`/.."/lib/*.jar; do
    CLASSPATH="$CLASSPATH:$jar"
done

# Use JAVA_HOME if set, otherwise look for java in PATH
if [ -x "$JAVA_HOME/bin/java" ]; then
    JAVA="$JAVA_HOME/bin/java"
else
    JAVA="`which java`"
fi

if [ "x$JAVA" = "x" ]; then
    echo "Java executable not found (hint: set JAVA_HOME)" >&2
    exit 1
fi

if [ "x$MAX_HEAP_SIZE" = "x" ]; then
    MAX_HEAP_SIZE="256M"
fi

"$JAVA" $JAVA_AGENT -ea -cp "$CLASSPATH" $JVM_OPTS -Xmx$MAX_HEAP_SIZE \
        -Dcassandra.storagedir="$cassandra_storagedir" \
        -Dlogback.configurationFile=logback-tools.xml \
        com.datastax.oss.cdc.cassandra.ChangeDataCapture "$@"

# vi:ai sw=4 ts=4 tw=0 et
