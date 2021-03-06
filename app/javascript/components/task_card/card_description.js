import React from "react"
import Typography from "@material-ui/core/Typography"
import CardContent from "@material-ui/core/CardContent"
import {makeStyles} from "@material-ui/core/styles"

const useStyles = makeStyles((theme) => ({
    root: {
        overflow: 'auto',
        padding: '8px 16px 0px 16px'
    },
    typography: {
        lineHeight: 1.4,
        fontWeight: 300,
        fontSize: '1.15rem'
    }
}))

const CardDescription = (props) => {

    const classes = useStyles()

    return (
        <CardContent className={classes.root}>
            <Typography variant="h6" color="textPrimary" className={classes.typography}>
                {props.task.description}
            </Typography>
        </CardContent>
    )

}

export default CardDescription