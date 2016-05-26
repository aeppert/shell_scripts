puppet_enable_and_ensure()
{
    sed -i "s/^\(.*enable.*=>.*\)\(false\)/\1true/" $1
    sed -i "s/^\(.*ensure.*=>.*\)\('stopped'\)/\1'running'/" $1
}

puppet_disable_and_stop()
{
    sed -i "s/^\(.*enable.*=>.*\)\(true\)/\1false/" $1
    sed -i "s/^\(.*ensure.*=>.*\)\('running'\)/\1'stopped'/" $1
}
